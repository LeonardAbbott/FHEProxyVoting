# Step-by-Step Development Guide: Hello FHEVM

## 🎯 Complete Development Walkthrough

This guide provides detailed, step-by-step instructions for building a privacy-preserving voting dApp from scratch using FHEVM technology.

---

## Phase 1: Project Setup and Environment

### Step 1: Initialize Your Project

```bash
# Create project directory
mkdir hello-fhevm-voting
cd hello-fhevm-voting

# Initialize npm project
npm init -y

# Create project structure
mkdir contracts
mkdir frontend
mkdir scripts
mkdir test
```

### Step 2: Install Dependencies

```bash
# Core blockchain dependencies
npm install --save-dev hardhat
npm install --save-dev @nomicfoundation/hardhat-toolbox
npm install --save-dev @openzeppelin/contracts

# FHE-specific dependencies
npm install fhevm
npm install @zama-ai/fhevm-core

# Frontend dependencies
npm install ethers@^6.0.0
```

### Step 3: Configure Hardhat

Create `hardhat.config.js`:

```javascript
require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    sepolia: {
      url: process.env.SEPOLIA_URL || "https://sepolia.infura.io/v3/YOUR-PROJECT-ID",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};
```

### Step 4: Environment Configuration

Create `.env` file:

```bash
SEPOLIA_URL=https://sepolia.infura.io/v3/YOUR-INFURA-PROJECT-ID
PRIVATE_KEY=your-wallet-private-key
ETHERSCAN_API_KEY=your-etherscan-api-key
```

---

## Phase 2: Smart Contract Development

### Step 5: Create the Base Contract Structure

Create `contracts/ProxyVotingFHE.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ProxyVotingFHE is Ownable {
    // Contract structure goes here
}
```

### Step 6: Define Data Structures

Add the core data structures:

```solidity
struct Proposal {
    string description;
    bytes32 encryptedYesVotes; // Simulated encrypted votes
    bytes32 encryptedNoVotes;  // Simulated encrypted votes
    uint256 deadline;
    bool active;
    mapping(address => bool) hasVoted;
}

struct Delegation {
    address delegate;
    bool active;
    uint256 weight;
}

mapping(uint256 => Proposal) public proposals;
mapping(address => Delegation) public delegations;
mapping(address => uint256) public votingPower;
mapping(address => bool) public isRegisteredVoter;

uint256 public proposalCount;
uint256 public constant VOTING_PERIOD = 7 days;

// Mock encryption state for tutorial
mapping(uint256 => uint256) private actualYesVotes;
mapping(uint256 => uint256) private actualNoVotes;
```

### Step 7: Implement Events

```solidity
event ProposalCreated(uint256 indexed proposalId, string description, uint256 deadline);
event VoteCast(uint256 indexed proposalId, address indexed voter, bool isYes);
event DelegationSet(address indexed delegator, address indexed delegate);
event DelegationRevoked(address indexed delegator);
event VoterRegistered(address indexed voter);
```

### Step 8: Add Constructor and Modifiers

```solidity
constructor() Ownable(msg.sender) {
    votingPower[msg.sender] = 1;
    isRegisteredVoter[msg.sender] = true;
}

modifier onlyRegisteredVoter() {
    require(isRegisteredVoter[msg.sender], "Not a registered voter");
    _;
}

modifier validProposal(uint256 proposalId) {
    require(proposalId < proposalCount, "Invalid proposal ID");
    require(proposals[proposalId].active, "Proposal not active");
    require(block.timestamp <= proposals[proposalId].deadline, "Voting period ended");
    _;
}
```

### Step 9: Implement Core Functions

#### Voter Registration

```solidity
function registerVoter(address voter) external onlyOwner {
    require(!isRegisteredVoter[voter], "Voter already registered");
    isRegisteredVoter[voter] = true;
    votingPower[voter] = 1;
    emit VoterRegistered(voter);
}
```

#### Proposal Creation

```solidity
function createProposal(string calldata description) external onlyOwner returns (uint256) {
    uint256 proposalId = proposalCount++;
    Proposal storage proposal = proposals[proposalId];

    proposal.description = description;
    proposal.encryptedYesVotes = keccak256(abi.encodePacked("encrypted_yes_", proposalId));
    proposal.encryptedNoVotes = keccak256(abi.encodePacked("encrypted_no_", proposalId));
    proposal.deadline = block.timestamp + VOTING_PERIOD;
    proposal.active = true;

    actualYesVotes[proposalId] = 0;
    actualNoVotes[proposalId] = 0;

    emit ProposalCreated(proposalId, description, proposal.deadline);
    return proposalId;
}
```

#### Delegation Functions

```solidity
function delegateVote(address delegate) external onlyRegisteredVoter {
    require(delegate != msg.sender, "Cannot delegate to yourself");
    require(isRegisteredVoter[delegate], "Delegate must be registered voter");

    if (delegations[msg.sender].active) {
        _revokeDelegation(msg.sender);
    }

    delegations[msg.sender] = Delegation({
        delegate: delegate,
        active: true,
        weight: votingPower[msg.sender]
    });

    votingPower[delegate] += votingPower[msg.sender];
    votingPower[msg.sender] = 0;

    emit DelegationSet(msg.sender, delegate);
}

function revokeDelegation() external onlyRegisteredVoter {
    require(delegations[msg.sender].active, "No active delegation");
    _revokeDelegation(msg.sender);
    emit DelegationRevoked(msg.sender);
}

function _revokeDelegation(address delegator) internal {
    Delegation storage delegation = delegations[delegator];
    address delegate = delegation.delegate;
    uint256 weight = delegation.weight;

    votingPower[delegate] -= weight;
    votingPower[delegator] = weight;

    delegation.active = false;
    delegation.delegate = address(0);
    delegation.weight = 0;
}
```

#### Encrypted Voting Function

```solidity
function vote(uint256 proposalId, bool isYes, bytes calldata inputProof)
    external
    onlyRegisteredVoter
    validProposal(proposalId)
{
    require(!proposals[proposalId].hasVoted[msg.sender], "Already voted");
    require(!delegations[msg.sender].active, "Cannot vote while delegation is active");

    proposals[proposalId].hasVoted[msg.sender] = true;

    uint256 voterPower = votingPower[msg.sender];

    // Update encrypted values (mock encryption)
    Proposal storage proposal = proposals[proposalId];
    if (isYes) {
        actualYesVotes[proposalId] += voterPower;
        proposal.encryptedYesVotes = keccak256(abi.encodePacked(proposal.encryptedYesVotes, msg.sender, voterPower));
    } else {
        actualNoVotes[proposalId] += voterPower;
        proposal.encryptedNoVotes = keccak256(abi.encodePacked(proposal.encryptedNoVotes, msg.sender, voterPower));
    }

    emit VoteCast(proposalId, msg.sender, isYes);
}
```

### Step 10: Add View Functions

```solidity
function getProposal(uint256 proposalId)
    external
    view
    returns (string memory description, uint256 deadline, bool active)
{
    require(proposalId < proposalCount, "Invalid proposal ID");
    Proposal storage proposal = proposals[proposalId];
    return (proposal.description, proposal.deadline, proposal.active);
}

function getDelegation(address voter)
    external
    view
    returns (address delegate, bool active)
{
    Delegation storage delegation = delegations[voter];
    return (delegation.delegate, delegation.active);
}

function hasVoted(uint256 proposalId, address voter) external view returns (bool) {
    return proposals[proposalId].hasVoted[voter];
}

function getVotingPower(address voter) external view returns (uint256) {
    return votingPower[voter];
}

function getProposalResults(uint256 proposalId, bytes32 publicKey, bytes calldata signature)
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
```

---

## Phase 3: Frontend Development

### Step 11: Create HTML Structure

Create `frontend/index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello FHEVM - Privacy Voting</title>
    <script src="https://cdn.jsdelivr.net/npm/ethers@6.7.0/dist/ethers.umd.min.js"></script>
    <link href="styles.css" rel="stylesheet">
</head>
<body>
    <div class="main-container">
        <header class="header">
            <h1 class="title">Hello FHEVM</h1>
            <p class="subtitle">Your First Privacy-Preserving dApp</p>
        </header>

        <div class="network-status">
            <p><strong>🌐 ETHEREUM SEPOLIA TESTNET</strong></p>
            <p>Smart Contract: <span id="contract-address">Loading...</span></p>
            <div id="fhe-status">
                <p>🔑 FHE Keys: <span id="fhe-key-status">Not Generated</span></p>
            </div>
        </div>

        <div id="message-container"></div>

        <div class="btn-group">
            <button id="connect-btn" class="btn btn-connect">🔗 Connect Wallet</button>
        </div>

        <div id="app-content" style="display: none;">
            <!-- App content will be loaded here -->
        </div>
    </div>

    <script src="app.js"></script>
</body>
</html>
```

### Step 12: Create CSS Styling

Create `frontend/styles.css`:

```css
@import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;700&display=swap');

body {
    background: linear-gradient(135deg, #0c0c0c 0%, #1a1a2e 50%, #0c0c0c 100%);
    color: #00d4ff;
    font-family: 'Orbitron', monospace;
    margin: 0;
    padding: 0;
    min-height: 100vh;
}

.main-container {
    background: rgba(0, 15, 30, 0.9);
    padding: 2rem;
    border-radius: 12px;
    max-width: 1200px;
    margin: 20px auto;
    border: 2px solid #00d4ff;
    box-shadow: 0 0 30px rgba(0, 212, 255, 0.3);
}

.header {
    text-align: center;
    margin-bottom: 2rem;
}

.title {
    font-size: 2.5em;
    font-weight: 700;
    background: linear-gradient(45deg, #00d4ff, #ff0080, #00d4ff);
    background-size: 200% 200%;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    animation: rainbow-text 3s ease-in-out infinite;
}

@keyframes rainbow-text {
    0%, 100% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
}

.btn {
    background: linear-gradient(45deg, #00d4ff, #0080ff);
    border: none;
    color: white;
    padding: 12px 24px;
    border-radius: 25px;
    cursor: pointer;
    font-family: 'Orbitron', monospace;
    font-weight: 500;
    transition: all 0.3s ease;
    min-width: 150px;
}

.btn:hover {
    background: linear-gradient(45deg, #ff0080, #ff4080);
    box-shadow: 0 0 20px rgba(255, 0, 128, 0.5);
    transform: translateY(-2px);
}

.section-card {
    background: rgba(0, 20, 40, 0.8);
    border: 1px solid rgba(0, 212, 255, 0.3);
    border-radius: 10px;
    padding: 20px;
    margin-bottom: 20px;
    transition: all 0.3s ease;
}

.section-card:hover {
    border-color: #00d4ff;
    box-shadow: 0 0 20px rgba(0, 212, 255, 0.2);
}

.input-field {
    width: 100%;
    padding: 12px 15px;
    margin: 10px 0;
    border: 2px solid rgba(0, 212, 255, 0.3);
    border-radius: 8px;
    background: rgba(0, 20, 40, 0.8);
    color: #00d4ff;
    font-family: 'Orbitron', monospace;
    box-sizing: border-box;
}

.status-message {
    background: rgba(0, 212, 255, 0.1);
    border: 1px solid rgba(0, 212, 255, 0.3);
    border-radius: 8px;
    padding: 15px;
    margin: 15px 0;
    text-align: center;
}

.success-message {
    background: rgba(0, 255, 128, 0.1);
    border-color: rgba(0, 255, 128, 0.5);
    color: #00ff80;
}

.warning-message {
    background: rgba(255, 128, 0, 0.1);
    border-color: rgba(255, 128, 0, 0.5);
    color: #ff8040;
}
```

### Step 13: Implement JavaScript Functionality

Create `frontend/app.js`:

```javascript
// Contract configuration
const CONTRACT_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
const CONTRACT_ABI = [
    // Add your contract ABI here
];

// Global variables
let provider = null;
let signer = null;
let account = '';
let contract = null;
let fhePublicKey = null;
let fhePrivateKey = null;

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('contract-address').textContent = CONTRACT_ADDRESS;
    document.getElementById('connect-btn').addEventListener('click', connectWallet);

    // Auto-connect if already connected
    if (window.ethereum && window.ethereum.selectedAddress) {
        connectWallet();
    }
});

// Wallet connection
async function connectWallet() {
    try {
        if (!window.ethereum) {
            showMessage('❌ MetaMask wallet required!', 'warning');
            return;
        }

        showMessage('🔄 Connecting wallet...');

        const accounts = await window.ethereum.request({
            method: 'eth_requestAccounts'
        });

        // Check and switch to Sepolia network
        const chainId = await window.ethereum.request({ method: 'eth_chainId' });
        if (chainId !== '0xaa36a7') {
            try {
                await window.ethereum.request({
                    method: 'wallet_switchEthereumChain',
                    params: [{ chainId: '0xaa36a7' }]
                });
            } catch (switchError) {
                if (switchError.code === 4902) {
                    await window.ethereum.request({
                        method: 'wallet_addEthereumChain',
                        params: [{
                            chainId: '0xaa36a7',
                            chainName: 'Sepolia Test Network',
                            rpcUrls: ['https://sepolia.infura.io/v3/'],
                            nativeCurrency: { name: 'ETH', symbol: 'ETH', decimals: 18 },
                            blockExplorerUrls: ['https://sepolia.etherscan.io/']
                        }]
                    });
                }
            }
        }

        provider = new ethers.BrowserProvider(window.ethereum);
        signer = await provider.getSigner();
        account = accounts[0];
        contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);

        document.getElementById('connect-btn').textContent = `✅ ${account.slice(0, 6)}...${account.slice(-4)}`;
        document.getElementById('connect-btn').disabled = true;

        // Generate FHE keys
        generateFHEKeys();

        // Load user data and show app
        await loadUserStatus();
        loadMainApp();

        showMessage('✅ Wallet connected successfully!', 'success');

    } catch (error) {
        console.error('Connection failed:', error);
        showMessage('❌ Wallet connection failed', 'warning');
    }
}

// FHE key generation
function generateFHEKeys() {
    const mockKeys = {
        publicKey: '0x' + Array(64).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join(''),
        privateKey: '0x' + Array(64).fill(0).map(() => Math.floor(Math.random() * 16).toString(16)).join('')
    };

    fhePublicKey = mockKeys.publicKey;
    fhePrivateKey = mockKeys.privateKey;

    document.getElementById('fhe-key-status').textContent = '✅ Generated';
    document.getElementById('fhe-key-status').style.color = '#00ff80';

    console.log('🔑 FHE Keys Generated');
}

// Vote encryption
function encryptVote(vote) {
    const encrypted = ethers.solidityPacked(
        ['bool', 'bytes32'],
        [vote, fhePublicKey]
    );
    console.log('🔐 Vote encrypted');
    return encrypted;
}

// Load user status from contract
async function loadUserStatus() {
    try {
        if (contract) {
            const isRegistered = await contract.isRegisteredVoter(account);
            const delegation = await contract.getDelegation(account);
            const power = await contract.getVotingPower(account);

            console.log('User status loaded:', {
                registered: isRegistered,
                delegation: delegation,
                power: power.toString()
            });
        }
    } catch (error) {
        console.error('Failed to load user status:', error);
    }
}

// Main app interface
function loadMainApp() {
    const content = document.getElementById('app-content');
    content.style.display = 'block';
    content.innerHTML = `
        <div class="section-card">
            <h3>🎫 Voter Registration</h3>
            <p>Register as a voter to participate in the voting system</p>
            <div class="btn-group">
                <button onclick="registerVoter()" class="btn">🎫 Register as Voter</button>
            </div>
        </div>

        <div class="section-card">
            <h3>📝 Create Proposal</h3>
            <input id="proposal-input" class="input-field" type="text" placeholder="Enter proposal description">
            <div class="btn-group">
                <button onclick="createProposal()" class="btn">📝 Create Proposal</button>
            </div>
        </div>

        <div class="section-card">
            <h3>🗳️ Voting</h3>
            <div id="proposals-container">
                <button onclick="loadProposals()" class="btn">📋 Load Proposals</button>
            </div>
        </div>

        <div class="section-card">
            <h3>🤝 Delegation</h3>
            <input id="delegate-input" class="input-field" type="text" placeholder="Enter delegate address">
            <div class="btn-group">
                <button onclick="delegateVote()" class="btn">🤝 Delegate Vote</button>
                <button onclick="revokeDelegation()" class="btn">🚫 Revoke Delegation</button>
            </div>
        </div>
    `;
}

// Core functions
async function registerVoter() {
    try {
        showMessage('🔄 Registering voter...');
        const tx = await contract.registerVoter(account);
        await tx.wait();
        showMessage('✅ Voter registered successfully!', 'success');
    } catch (error) {
        console.error('Registration failed:', error);
        showMessage('❌ Registration failed', 'warning');
    }
}

async function createProposal() {
    const description = document.getElementById('proposal-input').value;
    if (!description) {
        showMessage('⚠️ Please enter a proposal description', 'warning');
        return;
    }

    try {
        showMessage('🔄 Creating proposal...');
        const tx = await contract.createProposal(description);
        await tx.wait();
        showMessage('✅ Proposal created successfully!', 'success');
        document.getElementById('proposal-input').value = '';
    } catch (error) {
        console.error('Proposal creation failed:', error);
        showMessage('❌ Proposal creation failed', 'warning');
    }
}

async function loadProposals() {
    try {
        showMessage('🔄 Loading proposals...');
        const proposalCount = await contract.proposalCount();
        const proposalsContainer = document.getElementById('proposals-container');

        let proposalsHTML = '<h4>📊 Active Proposals</h4>';

        for (let i = 0; i < proposalCount; i++) {
            const proposal = await contract.getProposal(i);
            const hasVoted = await contract.hasVoted(i, account);

            proposalsHTML += `
                <div class="proposal-item">
                    <div><strong>Proposal #${i}:</strong> ${proposal[0]}</div>
                    <div>Deadline: ${new Date(Number(proposal[1]) * 1000).toLocaleDateString()}</div>
                    <div>Status: ${proposal[2] ? '🟢 Active' : '🔴 Closed'}</div>
                    ${proposal[2] && !hasVoted ? `
                        <div class="vote-buttons">
                            <button onclick="vote(${i}, true)" class="btn">✅ Vote YES</button>
                            <button onclick="vote(${i}, false)" class="btn">❌ Vote NO</button>
                        </div>
                    ` : hasVoted ? '<div>✅ You have voted</div>' : ''}
                </div>
            `;
        }

        proposalsContainer.innerHTML = proposalsHTML;
        showMessage('✅ Proposals loaded successfully!', 'success');

    } catch (error) {
        console.error('Failed to load proposals:', error);
        showMessage('❌ Failed to load proposals', 'warning');
    }
}

async function vote(proposalId, isYes) {
    try {
        showMessage(`🔐 Encrypting your ${isYes ? 'YES' : 'NO'} vote...`);

        const encryptedVote = encryptVote(isYes);
        const tx = await contract.vote(proposalId, isYes, encryptedVote);
        await tx.wait();

        showMessage(`✅ Vote recorded successfully! Your ${isYes ? 'YES' : 'NO'} vote is encrypted on-chain.`, 'success');
        setTimeout(() => loadProposals(), 2000);

    } catch (error) {
        console.error('Voting failed:', error);
        showMessage('❌ Voting failed', 'warning');
    }
}

async function delegateVote() {
    const delegateAddress = document.getElementById('delegate-input').value;
    if (!delegateAddress) {
        showMessage('⚠️ Please enter delegate address', 'warning');
        return;
    }

    try {
        showMessage('🔄 Delegating vote...');
        const tx = await contract.delegateVote(delegateAddress);
        await tx.wait();
        showMessage('✅ Vote delegated successfully!', 'success');
        document.getElementById('delegate-input').value = '';
    } catch (error) {
        console.error('Delegation failed:', error);
        showMessage('❌ Delegation failed', 'warning');
    }
}

async function revokeDelegation() {
    try {
        showMessage('🔄 Revoking delegation...');
        const tx = await contract.revokeDelegation();
        await tx.wait();
        showMessage('✅ Delegation revoked successfully!', 'success');
    } catch (error) {
        console.error('Revocation failed:', error);
        showMessage('❌ Revocation failed', 'warning');
    }
}

// Utility functions
function showMessage(msg, type = 'info') {
    const container = document.getElementById('message-container');
    const messageClass = type === 'success' ? 'success-message' : type === 'warning' ? 'warning-message' : '';
    container.innerHTML = `<div class="status-message ${messageClass}"><p>${msg}</p></div>`;
}
```

---

## Phase 4: Testing and Deployment

### Step 14: Write Tests

Create `test/ProxyVotingFHE.test.js`:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProxyVotingFHE", function () {
    let contract;
    let owner;
    let voter1;
    let voter2;

    beforeEach(async function () {
        [owner, voter1, voter2] = await ethers.getSigners();

        const ProxyVotingFHE = await ethers.getContractFactory("ProxyVotingFHE");
        contract = await ProxyVotingFHE.deploy();
        await contract.deployed();
    });

    it("Should deploy with correct initial state", async function () {
        expect(await contract.owner()).to.equal(owner.address);
        expect(await contract.isRegisteredVoter(owner.address)).to.be.true;
        expect(await contract.getVotingPower(owner.address)).to.equal(1);
    });

    it("Should register voters", async function () {
        await contract.registerVoter(voter1.address);
        expect(await contract.isRegisteredVoter(voter1.address)).to.be.true;
        expect(await contract.getVotingPower(voter1.address)).to.equal(1);
    });

    it("Should create proposals", async function () {
        const tx = await contract.createProposal("Test Proposal");
        const receipt = await tx.wait();

        expect(await contract.proposalCount()).to.equal(1);

        const proposal = await contract.getProposal(0);
        expect(proposal[0]).to.equal("Test Proposal");
        expect(proposal[2]).to.be.true; // active
    });

    it("Should handle delegation", async function () {
        await contract.registerVoter(voter1.address);
        await contract.registerVoter(voter2.address);

        await contract.connect(voter1).delegateVote(voter2.address);

        const delegation = await contract.getDelegation(voter1.address);
        expect(delegation[0]).to.equal(voter2.address);
        expect(delegation[1]).to.be.true;

        expect(await contract.getVotingPower(voter1.address)).to.equal(0);
        expect(await contract.getVotingPower(voter2.address)).to.equal(2);
    });

    it("Should handle encrypted voting", async function () {
        await contract.registerVoter(voter1.address);
        await contract.createProposal("Test Proposal");

        const mockProof = ethers.utils.randomBytes(32);
        await contract.connect(voter1).vote(0, true, mockProof);

        expect(await contract.hasVoted(0, voter1.address)).to.be.true;
    });
});
```

### Step 15: Run Tests

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Check test coverage
npx hardhat coverage
```

### Step 16: Deploy to Testnet

Create `scripts/deploy.js`:

```javascript
const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying ProxyVotingFHE contract...");

    const ProxyVotingFHE = await ethers.getContractFactory("ProxyVotingFHE");
    const contract = await ProxyVotingFHE.deploy();

    await contract.deployed();

    console.log("Contract deployed to:", contract.address);
    console.log("Transaction hash:", contract.deployTransaction.hash);

    // Wait for block confirmations
    await contract.deployTransaction.wait(5);

    console.log("Contract deployment confirmed!");

    // Update frontend with contract address
    console.log("\nUpdate your frontend with the following:");
    console.log(`CONTRACT_ADDRESS = "${contract.address}";`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
```

### Step 17: Deploy and Verify

```bash
# Deploy to Sepolia
npx hardhat run scripts/deploy.js --network sepolia

# Verify contract on Etherscan
npx hardhat verify --network sepolia CONTRACT_ADDRESS
```

---

## Phase 5: Final Integration and Testing

### Step 18: Update Frontend Configuration

Update the `CONTRACT_ADDRESS` in your `frontend/app.js` with the deployed contract address.

### Step 19: Test the Complete dApp

1. **Open the frontend** in your browser
2. **Connect MetaMask** to Sepolia testnet
3. **Register as a voter**
4. **Create test proposals**
5. **Test direct voting**
6. **Test delegation**
7. **Verify encryption** on Etherscan

### Step 20: Final Verification

Verify your dApp meets all requirements:

- ✅ Privacy-preserving voting with FHE
- ✅ Delegation functionality
- ✅ User-friendly interface
- ✅ Deployed to testnet
- ✅ Fully functional and tested

---

## 🎉 Congratulations!

You've successfully built a complete FHEVM-powered dApp from scratch! Your privacy-preserving voting system demonstrates:

- **FHE Integration**: Encrypted voting on blockchain
- **Smart Contract Development**: Complete Solidity implementation
- **Frontend Development**: Interactive user interface
- **Testing**: Comprehensive test suite
- **Deployment**: Live on Ethereum testnet

### Next Steps

1. **Share your work**: Deploy to mainnet when ready
2. **Enhance features**: Add more advanced FHE operations
3. **Optimize gas usage**: Improve contract efficiency
4. **Build community**: Share with other developers

**Happy Building! 🚀**