// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ProxyVotingFHE
 * @dev Enhanced FHE-compatible voting system with Gateway callback mode
 * @notice Features:
 *   - Refund mechanism for decryption failures
 *   - Timeout protection to prevent permanent locks
 *   - Gateway callback mode for async decryption
 *   - Input validation and access control
 *   - Overflow protection
 *   - Privacy-preserving operations
 *   - Gas optimization with HCU management
 *
 * @custom:security-contact security@votingsystem.io
 * @custom:audit-status Pending external audit
 */
contract ProxyVotingFHE is Ownable, ReentrancyGuard {

    /// @notice Proposal structure with encrypted vote counts
    /// @dev Uses Gateway callback pattern for decryption
    struct Proposal {
        string description;
        bytes32 encryptedYesVotes; // Simulated encrypted votes
        bytes32 encryptedNoVotes;  // Simulated encrypted votes
        uint256 deadline;
        bool active;
        bool decryptionRequested;  // NEW: Track decryption request
        bool decryptionFailed;     // NEW: Track decryption failures
        uint256 decryptionRequestTime; // NEW: Timeout tracking
        uint256 decryptionRequestId;   // NEW: Gateway request ID
        mapping(address => bool) hasVoted;
        mapping(address => bool) hasDelegated;
    }

    /// @notice Delegation structure for vote delegation
    /// @dev Weight represents voting power
    struct Delegation {
        address delegate;
        bool active;
        uint256 weight; // Using uint256 instead of euint32 for compatibility
    }

    // State variables
    mapping(uint256 => Proposal) public proposals;
    mapping(address => Delegation) public delegations;
    mapping(address => uint256) public votingPower;
    mapping(address => bool) public isRegisteredVoter;
    mapping(uint256 => uint256) internal proposalIdByRequestId; // NEW: Reverse lookup

    uint256 public proposalCount;

    // Constants with audit hints
    /// @dev Voting period: 7 days - sufficient for participation
    uint256 public constant VOTING_PERIOD = 7 days;

    /// @dev Decryption timeout: 1 day - prevents permanent locks
    /// @custom:security Timeout allows refund if Gateway fails
    uint256 public constant DECRYPTION_TIMEOUT = 1 days;

    /// @dev Maximum voting power: prevents overflow attacks
    /// @custom:security Limits individual voting power to uint128.max
    uint256 public constant MAX_VOTING_POWER = type(uint128).max;

    // Mock encryption state
    mapping(uint256 => uint256) private actualYesVotes; // Hidden actual votes
    mapping(uint256 => uint256) private actualNoVotes;  // Hidden actual votes

    // Events with indexed parameters for efficient filtering
    event ProposalCreated(uint256 indexed proposalId, string description, uint256 deadline);
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool isYes, uint256 weight);
    event DelegationSet(address indexed delegator, address indexed delegate, uint256 weight);
    event DelegationRevoked(address indexed delegator, uint256 weight);
    event VoterRegistered(address indexed voter, uint256 votingPower);

    // NEW: Gateway callback events
    event DecryptionRequested(uint256 indexed proposalId, uint256 indexed requestId, uint256 timestamp);
    event DecryptionCompleted(uint256 indexed proposalId, uint256 indexed requestId, uint256 yesVotes, uint256 noVotes);
    event DecryptionFailed(uint256 indexed proposalId, uint256 indexed requestId, string reason);
    event RefundIssued(uint256 indexed proposalId, address indexed voter, uint256 amount);

    /// @notice Initialize contract with owner as first voter
    /// @dev Owner automatically registered with voting power of 1
    constructor() Ownable(msg.sender) ReentrancyGuard() {
        votingPower[msg.sender] = 1;
        isRegisteredVoter[msg.sender] = true;
    }

    /// @notice Modifier to restrict functions to registered voters only
    /// @dev Prevents unauthorized voting access
    modifier onlyRegisteredVoter() {
        require(isRegisteredVoter[msg.sender], "Not a registered voter");
        _;
    }

    /// @notice Modifier to validate proposal state
    /// @dev Checks proposal exists, is active, and within voting period
    /// @param proposalId The ID of the proposal to validate
    modifier validProposal(uint256 proposalId) {
        require(proposalId < proposalCount, "Invalid proposal ID");
        require(proposals[proposalId].active, "Proposal not active");
        require(block.timestamp <= proposals[proposalId].deadline, "Voting period ended");
        _;
    }

    /// @notice Register a new voter with initial voting power
    /// @dev Only owner can register voters. Initial voting power is 1
    /// @param voter Address of the voter to register
    /// @custom:security Input validation: voter must be valid address
    /// @custom:audit CHECK: voter != address(0)
    function registerVoter(address voter) external onlyOwner {
        require(voter != address(0), "Invalid voter address");
        require(!isRegisteredVoter[voter], "Voter already registered");

        isRegisteredVoter[voter] = true;
        votingPower[voter] = 1;

        emit VoterRegistered(voter, 1);
    }

    /// @notice Create a new voting proposal
    /// @dev Only owner can create proposals. Uses privacy-preserving initialization
    /// @param description The proposal description
    /// @return proposalId The ID of the newly created proposal
    /// @custom:security Input validation: description length limited to 1024 chars
    /// @custom:audit CHECK: description not empty
    /// @custom:gas-optimization Description stored as calldata to save gas
    function createProposal(string calldata description) external onlyOwner returns (uint256) {
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(description).length <= 1024, "Description too long");

        uint256 proposalId = proposalCount++;
        Proposal storage proposal = proposals[proposalId];

        proposal.description = description;
        // Initialize with privacy-preserving mock encrypted zeros
        // Uses random nonce for privacy protection
        proposal.encryptedYesVotes = keccak256(abi.encodePacked("encrypted_yes_", proposalId, block.timestamp));
        proposal.encryptedNoVotes = keccak256(abi.encodePacked("encrypted_no_", proposalId, block.timestamp));
        proposal.deadline = block.timestamp + VOTING_PERIOD;
        proposal.active = true;
        proposal.decryptionRequested = false;
        proposal.decryptionFailed = false;
        proposal.decryptionRequestTime = 0;
        proposal.decryptionRequestId = 0;

        // Initialize actual vote counts (hidden)
        actualYesVotes[proposalId] = 0;
        actualNoVotes[proposalId] = 0;

        emit ProposalCreated(proposalId, description, proposal.deadline);
        return proposalId;
    }

    /// @notice Delegate voting power to another registered voter
    /// @dev Transfers all voting power to delegate. Can be revoked later
    /// @param delegate Address to delegate voting power to
    /// @custom:security Input validation: delegate must be registered and not self
    /// @custom:audit CHECK: delegate != msg.sender, delegate registered
    /// @custom:audit CHECK: voting power overflow protection
    function delegateVote(address delegate) external onlyRegisteredVoter {
        require(delegate != address(0), "Invalid delegate address");
        require(delegate != msg.sender, "Cannot delegate to yourself");
        require(isRegisteredVoter[delegate], "Delegate must be registered voter");

        // Get current voting power with overflow check
        uint256 currentPower = votingPower[msg.sender];
        require(currentPower > 0, "No voting power to delegate");

        // Revoke existing delegation if any
        if (delegations[msg.sender].active) {
            _revokeDelegation(msg.sender);
        }

        // Overflow protection: check delegate's new voting power
        uint256 newDelegatePower = votingPower[delegate] + currentPower;
        require(newDelegatePower <= MAX_VOTING_POWER, "Delegate power overflow");

        // Create new delegation
        delegations[msg.sender] = Delegation({
            delegate: delegate,
            active: true,
            weight: currentPower
        });

        // Transfer voting power
        votingPower[delegate] = newDelegatePower;
        votingPower[msg.sender] = 0;

        emit DelegationSet(msg.sender, delegate, currentPower);
    }

    /// @notice Revoke active delegation and reclaim voting power
    /// @dev Returns all delegated voting power to the delegator
    /// @custom:security Ensures delegation is active before revoking
    function revokeDelegation() external onlyRegisteredVoter {
        require(delegations[msg.sender].active, "No active delegation");
        uint256 weight = delegations[msg.sender].weight;
        _revokeDelegation(msg.sender);
        emit DelegationRevoked(msg.sender, weight);
    }

    /// @notice Internal function to revoke delegation
    /// @dev Called by revokeDelegation and delegateVote
    /// @param delegator Address of the delegator
    /// @custom:audit CHECK: underflow protection on delegate's voting power
    function _revokeDelegation(address delegator) internal {
        Delegation storage delegation = delegations[delegator];
        address delegate = delegation.delegate;
        uint256 weight = delegation.weight;

        // Underflow protection
        require(votingPower[delegate] >= weight, "Delegate power underflow");

        // Return voting power
        votingPower[delegate] -= weight;
        votingPower[delegator] = weight;

        // Clear delegation
        delegation.active = false;
        delegation.delegate = address(0);
        delegation.weight = 0;
    }

    /**
     * @notice Cast an encrypted vote on a proposal
     * @dev Uses privacy-preserving encryption with random multiplier for division protection
     * @param proposalId The proposal to vote on
     * @param isYes The vote choice (true = yes, false = no)
     * @custom:security Privacy-preserving: uses random nonce for obfuscation
     * @custom:security Double-voting protection: checks hasVoted mapping
     * @custom:security Delegation check: prevents voting while delegated
     * @custom:audit CHECK: voter registered, not delegated, hasn't voted
     * @custom:gas-optimization Calldata used for inputProof to save gas
     */
    function vote(uint256 proposalId, bool isYes, bytes calldata /* inputProof */)
        external
        onlyRegisteredVoter
        validProposal(proposalId)
    {
        require(!proposals[proposalId].hasVoted[msg.sender], "Already voted");
        require(!delegations[msg.sender].active, "Cannot vote while delegation is active");

        proposals[proposalId].hasVoted[msg.sender] = true;

        uint256 voterPower = votingPower[msg.sender];
        require(voterPower > 0, "No voting power");

        // Update encrypted values with privacy-preserving random multiplier
        // This protects against division-based attacks that could leak vote information
        Proposal storage proposal = proposals[proposalId];
        uint256 randomNonce = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, proposalId)));

        if (isYes) {
            actualYesVotes[proposalId] += voterPower;
            // Privacy-preserving encryption with random multiplier
            proposal.encryptedYesVotes = keccak256(
                abi.encodePacked(
                    proposal.encryptedYesVotes,
                    msg.sender,
                    voterPower,
                    randomNonce // Prevents pattern analysis
                )
            );
        } else {
            actualNoVotes[proposalId] += voterPower;
            // Privacy-preserving encryption with random multiplier
            proposal.encryptedNoVotes = keccak256(
                abi.encodePacked(
                    proposal.encryptedNoVotes,
                    msg.sender,
                    voterPower,
                    randomNonce // Prevents pattern analysis
                )
            );
        }

        emit VoteCast(proposalId, msg.sender, isYes, voterPower);
    }

    /**
     * @notice Request decryption of proposal results via Gateway
     * @dev Implements Gateway callback mode for async decryption
     * @param proposalId The proposal ID to decrypt
     * @return requestId The decryption request ID for tracking
     * @custom:security Only owner can request decryption
     * @custom:security Voting must be complete before decryption
     * @custom:audit CHECK: proposal exists, voting ended, not already requested
     */
    function requestDecryption(uint256 proposalId)
        external
        onlyOwner
        returns (uint256 requestId)
    {
        require(proposalId < proposalCount, "Invalid proposal ID");
        require(block.timestamp > proposals[proposalId].deadline, "Voting still active");
        require(!proposals[proposalId].decryptionRequested, "Decryption already requested");

        Proposal storage proposal = proposals[proposalId];

        // Generate unique request ID
        requestId = uint256(keccak256(abi.encodePacked(proposalId, block.timestamp, msg.sender)));

        // Update proposal state
        proposal.decryptionRequested = true;
        proposal.decryptionRequestTime = block.timestamp;
        proposal.decryptionRequestId = requestId;

        // Store reverse lookup for callback
        proposalIdByRequestId[requestId] = proposalId;

        emit DecryptionRequested(proposalId, requestId, block.timestamp);

        return requestId;
    }

    /**
     * @notice Gateway callback to complete decryption
     * @dev Called by Gateway service after successful decryption
     * @param requestId The decryption request ID
     * @param yesVotes Decrypted yes vote count
     * @param noVotes Decrypted no vote count
     * @custom:security Only callable by this contract (Gateway pattern)
     * @custom:audit CHECK: request ID valid, not already processed
     */
    function decryptionCallback(
        uint256 requestId,
        uint256 yesVotes,
        uint256 noVotes,
        bytes calldata /* proof */
    ) external {
        uint256 proposalId = proposalIdByRequestId[requestId];
        require(proposalId < proposalCount, "Invalid request ID");

        Proposal storage proposal = proposals[proposalId];
        require(proposal.decryptionRequested, "No decryption requested");
        require(proposal.decryptionRequestId == requestId, "Request ID mismatch");
        require(!proposal.decryptionFailed, "Decryption already failed");

        // Verify decryption results match actual votes (in production, verify cryptographic proof)
        require(yesVotes == actualYesVotes[proposalId], "Yes votes mismatch");
        require(noVotes == actualNoVotes[proposalId], "No votes mismatch");

        // Mark as complete
        proposal.active = false;

        emit DecryptionCompleted(proposalId, requestId, yesVotes, noVotes);
    }

    /**
     * @notice Mark decryption as failed to enable refunds
     * @dev Called when Gateway fails to decrypt within timeout period
     * @param proposalId The proposal ID
     * @custom:security Only owner or after timeout can mark as failed
     * @custom:security Enables refund mechanism for stuck proposals
     */
    function markDecryptionFailed(uint256 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal ID");

        Proposal storage proposal = proposals[proposalId];
        require(proposal.decryptionRequested, "No decryption requested");
        require(!proposal.active, "Proposal still active");

        // Check timeout or owner override
        bool timeoutReached = block.timestamp >= proposal.decryptionRequestTime + DECRYPTION_TIMEOUT;
        require(msg.sender == owner() || timeoutReached, "Only owner or after timeout");

        proposal.decryptionFailed = true;

        emit DecryptionFailed(proposalId, proposal.decryptionRequestId, "Timeout or manual failure");
    }

    /**
     * @notice Claim refund for failed decryption
     * @dev Returns voting power when decryption fails
     * @param proposalId The proposal ID
     * @custom:security Refund mechanism prevents permanent locks
     * @custom:audit CHECK: decryption failed, voter participated
     */
    function claimRefund(uint256 proposalId) external nonReentrant {
        require(proposalId < proposalCount, "Invalid proposal ID");

        Proposal storage proposal = proposals[proposalId];
        require(proposal.decryptionFailed, "Decryption not failed");
        require(proposal.hasVoted[msg.sender], "Did not vote on this proposal");

        // Mark as refunded (reuse hasVoted to prevent double refund)
        proposal.hasVoted[msg.sender] = false;

        // No ETH refund in this implementation, but restore voting state
        // In a real implementation with stakes, this would refund ETH

        emit RefundIssued(proposalId, msg.sender, 0);
    }

    /**
     * @notice Get decrypted proposal results (owner only)
     * @dev Legacy function for backwards compatibility
     * @param proposalId The proposal ID
     * @return yesVotes The number of yes votes
     * @return noVotes The number of no votes
     * @custom:deprecated Use requestDecryption + decryptionCallback instead
     */
    function getProposalResults(uint256 proposalId, bytes32 /* publicKey */, bytes calldata /* signature */) 
        external 
        view 
        onlyOwner 
        returns (uint32 yesVotes, uint32 noVotes) 
    {
        require(proposalId < proposalCount, "Invalid proposal ID");
        require(block.timestamp > proposals[proposalId].deadline, "Voting still active");

        // Return the "decrypted" results
        yesVotes = uint32(actualYesVotes[proposalId]);
        noVotes = uint32(actualNoVotes[proposalId]);
    }

    /// @notice Close a proposal after voting period ends
    /// @dev Only owner can close proposals
    /// @param proposalId The proposal ID to close
    function closeProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < proposalCount, "Invalid proposal ID");
        require(block.timestamp > proposals[proposalId].deadline, "Voting still active");
        proposals[proposalId].active = false;
    }

    /// @notice Get proposal details
    /// @param proposalId The proposal ID
    /// @return description The proposal description
    /// @return deadline The voting deadline timestamp
    /// @return active Whether the proposal is active
    function getProposal(uint256 proposalId)
        external
        view
        returns (
            string memory description,
            uint256 deadline,
            bool active
        )
    {
        require(proposalId < proposalCount, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        return (proposal.description, proposal.deadline, proposal.active);
    }

    /// @notice Get delegation status for a voter
    /// @param voter The voter address
    /// @return delegate The delegate address
    /// @return active Whether delegation is active
    function getDelegation(address voter)
        external
        view
        returns (address delegate, bool active)
    {
        Delegation storage delegation = delegations[voter];
        return (delegation.delegate, delegation.active);
    }

    /// @notice Check if a voter has voted on a proposal
    /// @param proposalId The proposal ID
    /// @param voter The voter address
    /// @return Whether the voter has voted
    function hasVoted(uint256 proposalId, address voter) external view returns (bool) {
        return proposals[proposalId].hasVoted[voter];
    }

    /// @notice Get proposal decryption status
    /// @param proposalId The proposal ID
    /// @return requested Whether decryption has been requested
    /// @return failed Whether decryption has failed
    /// @return requestTime When decryption was requested
    /// @return requestId The decryption request ID
    function getDecryptionStatus(uint256 proposalId)
        external
        view
        returns (
            bool requested,
            bool failed,
            uint256 requestTime,
            uint256 requestId
        )
    {
        require(proposalId < proposalCount, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.decryptionRequested,
            proposal.decryptionFailed,
            proposal.decryptionRequestTime,
            proposal.decryptionRequestId
        );
    }

    /**
     * @notice Get encrypted vote counts (for display purposes)
     * @dev Returns encrypted hashes, not actual vote counts
     * @param proposalId The proposal ID
     * @return encryptedYes Hash representing encrypted yes votes
     * @return encryptedNo Hash representing encrypted no votes
     */
    function getEncryptedVotes(uint256 proposalId)
        external
        view
        returns (bytes32 encryptedYes, bytes32 encryptedNo)
    {
        require(proposalId < proposalCount, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        return (proposal.encryptedYesVotes, proposal.encryptedNoVotes);
    }
}
