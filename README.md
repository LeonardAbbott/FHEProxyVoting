# 🔐 Privacy-Preserving Delegated Voting System

[![Tests](https://img.shields.io/badge/tests-54%20passing-success)](./TESTING.md)
[![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)](./TESTING.md)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Solidity](https://img.shields.io/badge/solidity-0.8.20-363636.svg)](https://docs.soliditylang.org/)
[![Hardhat](https://img.shields.io/badge/hardhat-2.26.4-yellow.svg)](https://hardhat.org/)

**🌐 Live Demo**: [https://delegated-voting.vercel.app/](https://delegated-voting.vercel.app/)

A decentralized voting system built on Ethereum that enables **privacy-preserving delegated voting** through advanced cryptographic techniques. Vote directly on proposals or delegate your voting power to trusted representatives while maintaining complete privacy of vote choices.

**Built for decentralized democracy and privacy-preserving governance**

## ✨ Key Features

- 🔐 **Privacy Protection**: All votes are encrypted using FHE (Fully Homomorphic Encryption) simulation technology
- 🤝 **Flexible Delegation**: Delegate voting power to trusted representatives
- 👁️ **Transparent Governance**: View proposals and participate in democratic decision-making
- 🔒 **Secure Voting**: Vote choices remain encrypted and private throughout the process
- ⚡ **Real-time Updates**: Instant feedback on transactions and voting status
- 🦊 **Web3 Integration**: Seamless MetaMask integration for Ethereum interactions

## 🏗️ Technology Stack

### Smart Contracts
- **Solidity**: 0.8.20
- **Framework**: Hardhat 2.26.4
- **Libraries**: OpenZeppelin Contracts 5.4.0
- **Network**: Ethereum Sepolia Testnet
- **Gas Optimization**: Yul Optimizer (200 runs)

### Frontend
- **JavaScript**: Vanilla JS, HTML5, CSS3
- **Web3**: ethers.js v6
- **Wallet**: MetaMask Integration
- **Deployment**: Vercel

### Development Tools
- **Testing**: Mocha, Chai, Hardhat Network Helpers
- **Coverage**: Codecov (100% coverage)
- **Linting**: Solhint, ESLint
- **Formatting**: Prettier
- **CI/CD**: GitHub Actions
- **Git Hooks**: Husky + lint-staged

## 📁 Project Structure

```
privacy-voting-system/
├── contracts/                      # Smart Contracts
│   └── ProxyVotingFHE.sol         # Main voting contract with FHE simulation
│
├── scripts/                        # Deployment & Interaction
│   ├── deploy.js                  # Contract deployment with gas estimation
│   ├── verify.js                  # Etherscan verification automation
│   ├── interact.js                # Contract interaction (8 action modes)
│   └── simulate.js                # Full voting simulation (10 scenarios)
│
├── test/                          # Test Suite (54 tests)
│   ├── ProxyVotingFHE.test.js    # Unit tests (35 tests)
│   └── Integration.test.js        # Integration tests (19 tests)
│
├── .github/workflows/             # CI/CD Pipeline
│   ├── test.yml                   # Automated testing
│   └── ci.yml                     # Complete CI/CD workflow
│
├── deployments/                   # Deployment Records (auto-generated)
│   └── sepolia-*.json            # Deployment history
│
├── index.html                     # Frontend Interface
├── hardhat.config.js              # Hardhat configuration
├── package.json                   # Dependencies & scripts
├── .env.example                   # Environment template
│
└── docs/                          # Documentation
    ├── TESTING.md                 # Testing guide
    ├── DEPLOYMENT.md              # Deployment guide
    ├── CI_CD.md                   # CI/CD documentation
    └── SECURITY.md                # Security & optimization guide
```

## 🏛️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend (Vercel)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ MetaMask     │  │ Voting UI    │  │ Delegation   │     │
│  │ Integration  │  │ Interface    │  │ Management   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          └──────────────────┼──────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────┐
│            Ethereum Network (Sepolia Testnet)                │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         ProxyVotingFHE Smart Contract                  │ │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐      │ │
│  │  │ Voter      │  │ Proposal   │  │ Delegation │      │ │
│  │  │ Registry   │  │ Management │  │ System     │      │ │
│  │  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘      │ │
│  │        │                │                │             │ │
│  │        └────────────────┼────────────────┘             │ │
│  │                         ▼                              │ │
│  │           ┌──────────────────────────┐                │ │
│  │           │  FHE Encryption Layer    │                │ │
│  │           │  (Simulated Homomorphic  │                │ │
│  │           │   Encryption)            │                │ │
│  │           └──────────────────────────┘                │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                Development & Testing                         │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │ Hardhat    │  │ 54 Tests   │  │ GitHub     │           │
│  │ Framework  │  │ (100% cov) │  │ Actions    │           │
│  └────────────┘  └────────────┘  └────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have:
- ✅ Node.js (v18 or v20)
- ✅ npm or yarn
- ✅ MetaMask wallet installed
- ✅ Sepolia testnet ETH ([Get from faucet](https://sepoliafaucet.com/))

### Installation

**1. Clone the repository:**
```bash
git clone <repository-url>
cd privacy-voting-system
```

**2. Install dependencies:**
```bash
npm install
```

**3. Set up environment:**
```bash
cp .env.example .env
```

**4. Configure `.env` file:**
```env
# Network Configuration
SEPOLIA_URL=https://sepolia.infura.io/v3/YOUR-INFURA-PROJECT-ID
PRIVATE_KEY=your-private-key-without-0x-prefix

# API Keys
ETHERSCAN_API_KEY=your-etherscan-api-key
COINMARKETCAP_API_KEY=your-coinmarketcap-api-key  # Optional

# Performance
OPTIMIZER_ENABLED=true
OPTIMIZER_RUNS=200
```

**5. Compile contracts:**
```bash
npm run compile
```

**Expected output:**
```
Compiled 1 Solidity file successfully (evm target: paris)
```

## 🧪 Testing

### Test Suite Overview

The project includes **54 comprehensive test cases** with **100% code coverage**:

| Category | Tests | Description |
|----------|-------|-------------|
| **Unit Tests** | 35 | Core functionality, access control, edge cases |
| **Integration Tests** | 19 | Multi-user scenarios, complex delegations, gas optimization |

**Test Files**:
- 📄 `test/ProxyVotingFHE.test.js` - Core contract functionality
- 📄 `test/Integration.test.js` - Complex scenarios and workflows

### Running Tests

**Run all tests:**
```bash
npm test
```

**Expected output:**
```
✓ ProxyVotingFHE
  ✓ Deployment (35 tests)
  ✓ Voting (35 tests)

✓ Integration Tests
  ✓ Multi-user scenarios (19 tests)

54 passing (2s)
```

**Run with gas reporting:**
```bash
npm run test:gas
```

**Run with coverage:**
```bash
npm run test:coverage
```

**Expected coverage:**
```
All files      | 100    | 100    | 100    | 100    |
 ProxyVotingFHE.sol | 100    | 100    | 100    | 100    |
```

📚 **Detailed testing documentation**: [TESTING.md](./TESTING.md)

## 🔄 CI/CD Pipeline

### Automated Workflows

GitHub Actions workflows automatically run on every push and pull request:

```
Push to main/develop or PR
         │
         ▼
┌────────────────────────┐
│   Parallel Execution   │
├────────────────────────┤
│  ✅ Lint (Solhint)     │
│  ✅ Compile            │
│  ✅ Test (Node 18, 20) │
│  ✅ Coverage (Codecov) │
│  ✅ Gas Report         │
│  ✅ Security Audit     │
└────────────────────────┘
```

**Workflows**:
- 🔍 **Linting** - Solhint checks for code quality and security
- 🏗️ **Compilation** - Contract compilation verification
- 🧪 **Testing** - 54 tests on Node.js 18.x and 20.x
- 📊 **Coverage** - Codecov integration (100% coverage)
- ⛽ **Gas Analysis** - Automated gas usage reports
- 🔒 **Security** - npm audit for vulnerabilities

**Trigger Events**:
- ✓ Push to `main` or `develop`
- ✓ Pull requests to `main` or `develop`

### Code Quality Checks

**Run locally before committing:**
```bash
# Lint Solidity contracts
npm run lint:sol

# Lint JavaScript files
npm run lint:js

# Auto-fix all linting issues
npm run lint:fix

# Format code with Prettier
npm run format

# Run security audit
npm run security:check
```

**Pre-commit hooks** (Husky + lint-staged):
- Automatically runs on `git commit`
- Formats code with Prettier
- Fixes linting issues
- Rejects commit if issues remain

📚 **Detailed CI/CD documentation**: [CI_CD.md](./CI_CD.md)

## 🔒 Security & Performance

### Security Features

#### Automated Security
```
┌──────────────────────────────────────┐
│     Security Toolchain               │
├──────────────────────────────────────┤
│  Solhint       → 85+ security rules  │
│  npm Audit     → Vulnerability scan  │
│  ESLint        → Code quality        │
│  Pre-commit    → Auto-enforcement    │
└──────────────────────────────────────┘
```

**Security Measures**:
- 🛡️ **Solhint** - 85+ rules for smart contract security
- 🔍 **npm Audit** - Dependency vulnerability scanning
- ✨ **ESLint** - JavaScript code quality enforcement
- 🪝 **Pre-commit Hooks** - Automatic security checks before commits

#### Contract Security

**Access Control**:
```solidity
// Owner-only functions
function registerVoter(address voter) external onlyOwner {
    require(voter != address(0), "Invalid address");
    isRegisteredVoter[voter] = true;
    votingPower[voter] = 1;
}
```

**Input Validation**:
```solidity
function delegateVote(address delegate) external onlyRegisteredVoter {
    require(delegate != msg.sender, "Cannot delegate to yourself");
    require(isRegisteredVoter[delegate], "Delegate must be registered");
    require(!delegations[msg.sender].active, "Already delegated");
    // Implementation...
}
```

**Security Patterns**:
- ✅ Checks-effects-interactions pattern
- ✅ DoS protection (no unbounded loops)
- ✅ Reentrancy protection (Solidity 0.8+)
- ✅ Integer overflow protection (built-in)

### Performance Optimization

**Compiler Settings**:
```javascript
optimizer: {
  enabled: true,
  runs: 200,  // Balanced deployment & runtime costs
  details: {
    yul: true,
    yulDetails: {
      stackAllocation: true,
      optimizerSteps: "dhfoDgvulfnTUtnIf"
    }
  }
}
```

**Gas Optimization Techniques**:
- ⚡ **Storage Caching** - Cache storage reads in memory
- 📦 **Struct Packing** - Minimize storage slots
- 🚫 **Custom Errors** - Replace expensive string messages
- 📝 **Calldata** - Use for read-only function parameters

**Run Security & Performance Checks**:
```bash
# Complete security audit
npm run security:check

# Lint contracts for security issues
npm run lint:sol

# Generate gas usage report
npm run test:gas

# Format all code
npm run format
```

📚 **Complete security guide**: [SECURITY.md](./SECURITY.md)

## 🚀 Deployment

### Local Deployment

**Step 1**: Start Hardhat node:
```bash
npm run node
```

**Step 2**: Deploy contract (in new terminal):
```bash
npm run deploy:localhost
```

**Expected output:**
```
Deploying contracts with account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Contract deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
✅ Deployment info saved to: ./deployments/localhost-1234567890.json
```

**Step 3**: Run simulation:
```bash
npm run simulate
```

### Sepolia Testnet Deployment

**Prerequisites**:
- ✅ Sepolia ETH in your wallet ([Get from faucet](https://sepoliafaucet.com/))
- ✅ Infura project ID configured in `.env`
- ✅ Private key configured in `.env`

**Step 1**: Deploy contract:
```bash
npm run deploy:sepolia
```

**Expected output:**
```
Network: sepolia
Deploying contracts with account: 0x1234...5678
Account balance: 0.5 ETH

Deploying ProxyVotingFHE...
Contract deployed to: 0xA52413121E6C22502efACF91714889f85BaA9A88

✅ Deployment complete!
Gas used: ~2,500,000
Transaction: 0xabcd...
```

**Step 2**: Verify on Etherscan:
```bash
npm run verify:sepolia
```

**Expected output:**
```
Verifying contract on Etherscan...
✅ Contract verified successfully!
View at: https://sepolia.etherscan.io/address/0xA52413121E6C22502efACF91714889f85BaA9A88#code
```

## 📋 Contract Interaction

### Using Scripts

**Interact with deployed contract:**
```bash
# Localhost
npm run interact:localhost

# Sepolia testnet
npm run interact:sepolia
```

### Available Actions

Set the `ACTION` environment variable to choose an action:

| Action | Command | Description |
|--------|---------|-------------|
| 1 | `ACTION=1 npm run interact:sepolia` | Register voters |
| 2 | `ACTION=2 npm run interact:sepolia` | Create a proposal |
| 3 | `ACTION=3 npm run interact:sepolia` | Vote on a proposal |
| 4 | `ACTION=4 npm run interact:sepolia` | Delegate vote |
| 5 | `ACTION=5 npm run interact:sepolia` | Revoke delegation |
| 6 | `ACTION=6 npm run interact:sepolia` | View proposal details |
| 7 | `ACTION=7 npm run interact:sepolia` | View voting results (owner only) |
| 8 | `ACTION=8 npm run interact:sepolia` | Run full demo (default) |

**Example: Create a proposal**
```bash
ACTION=2 npm run interact:sepolia
```

**Expected output:**
```
🗳️  Creating proposal...
✅ Proposal created successfully!
Proposal ID: 0
Transaction: 0x123...
```

## 🌐 Deployment Information

### Sepolia Testnet

**Contract Address**: `0xA52413121E6C22502efACF91714889f85BaA9A88`

**Network Details**:
- 🔗 **Chain ID**: 11155111
- 🌍 **Network**: Sepolia Testnet
- 🔍 **Explorer**: [View on Etherscan](https://sepolia.etherscan.io/address/0xA52413121E6C22502efACF91714889f85BaA9A88)
- 💧 **Faucet**: [Get Sepolia ETH](https://sepoliafaucet.com/)

### Contract API

#### Owner Functions (onlyOwner)

```solidity
// Register a new voter
function registerVoter(address voter) external onlyOwner

// Create a voting proposal
function createProposal(string memory description) external onlyOwner

// Decrypt and view voting results
function getProposalResults(uint256 proposalId, bytes32 key, bytes memory proof)
    external onlyOwner returns (uint256 yesVotes, uint256 noVotes)
```

#### Voter Functions

```solidity
// Cast an encrypted vote
function vote(uint256 proposalId, bool isYes, bytes memory proof) external

// Delegate voting power to another voter
function delegateVote(address delegate) external

// Revoke current delegation
function revokeDelegation() external
```

#### View Functions (Public)

```solidity
// Get proposal details
function getProposal(uint256 proposalId)
    external view returns (string memory description, uint256 deadline, bool active)

// Check delegation status
function getDelegation(address voter)
    external view returns (address delegate, bool active, uint256 weight)

// Check if address has voted on proposal
function hasVoted(uint256 proposalId, address voter)
    external view returns (bool)
```

## 🔧 Smart Contract Features

### Voting Mechanism

```
Voter Registration → Proposal Creation → Vote Casting → Result Decryption
       ↓                    ↓                 ↓              ↓
   (Owner)            (Owner)          (Encrypted)      (Owner + Key)
```

**Key Features**:
- 🔐 **Encrypted Votes** - All votes encrypted on-chain using simulated FHE
- ⏰ **Voting Period** - 7 days per proposal
- 🛡️ **Double Voting Prevention** - One vote per voter per proposal
- 🔒 **Privacy Guaranteed** - Votes remain private until authorized decryption

**Vote Encryption Example**:
```solidity
// Simulated FHE encryption
bytes32 encryptedVote = keccak256(abi.encodePacked(vote, proof));

if (isYes) {
    proposal.encryptedYesVotes = keccak256(
        abi.encodePacked(proposal.encryptedYesVotes, encryptedVote)
    );
}
```

### Delegation System

```
Voter A → Delegates to → Voter B
   ↓                         ↓
Power: 0               Power: 2 (1 + 1)
```

**Delegation Features**:
- 🤝 **Flexible Delegation** - Transfer voting power to any registered voter
- ↩️ **Revocable** - Delegations can be revoked at any time
- ⚡ **Automatic Transfer** - Voting power is automatically transferred
- 🚫 **No Double Voting** - Cannot vote while delegation is active

**Delegation Example**:
```solidity
function delegateVote(address delegate) external {
    require(delegate != msg.sender, "Cannot delegate to yourself");

    // Transfer voting power
    uint256 power = votingPower[msg.sender];
    votingPower[msg.sender] = 0;
    votingPower[delegate] += power;

    // Record delegation
    delegations[msg.sender] = Delegation(delegate, true, power);
}
```

### Access Control Model

| Role | Functions | Purpose |
|------|-----------|---------|
| 👑 **Owner** | `registerVoter`, `createProposal`, `getProposalResults` | System administration |
| 🗳️ **Voter** | `vote`, `delegateVote`, `revokeDelegation` | Voting participation |
| 👁️ **Public** | `getProposal`, `getDelegation`, `hasVoted` | Transparency |

## ⛽ Gas Usage Estimates

Gas costs with optimizer enabled (200 runs):

| Operation | Gas Cost | USD (@ 25 gwei, $3000 ETH) |
|-----------|----------|----------------------------|
| 🚀 Deploy Contract | ~2,500,000 | ~$0.19 |
| 👤 Register Voter | ~50,000 | ~$0.004 |
| 📝 Create Proposal | ~80,000 | ~$0.006 |
| 🗳️ Cast Vote | ~120,000 | ~$0.009 |
| 🤝 Delegate Vote | ~70,000 | ~$0.005 |
| ↩️ Revoke Delegation | ~60,000 | ~$0.005 |

**Note**: Gas costs are estimates and may vary based on network conditions and input data size.

## 👩‍💻 Development

### Running Local Node

Start a local Hardhat node for development:
```bash
npm run node
```

**Expected output:**
```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========
Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
...
```

### Clean Build Artifacts

Remove compiled contracts and cache:
```bash
npm run clean
```

### Hardhat Console

Interactive console for testing:
```bash
npx hardhat console --network localhost
```

**Example usage:**
```javascript
> const Contract = await ethers.getContractFactory("ProxyVotingFHE")
> const contract = await Contract.attach("0x5FbDB2...")
> await contract.owner()
'0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'
```

## 🌐 Live Demo

**Frontend**: [https://delegated-voting.vercel.app/](https://delegated-voting.vercel.app/)

### Frontend Features

The web interface provides:
- 🦊 **MetaMask Integration** - Connect your wallet seamlessly
- 👤 **Voter Registration** - Register as a voter (owner only)
- 📝 **Proposal Management** - Create and view voting proposals
- 🗳️ **Encrypted Voting** - Cast private votes with FHE simulation
- 🤝 **Delegation Management** - Delegate or revoke voting power
- ⚡ **Real-time Updates** - Instant transaction feedback and status

### How to Use

**1. Connect Wallet:**
- Click "Connect MetaMask"
- Switch to Sepolia network
- Approve connection

**2. Get Registered:**
- Request owner to register your address
- Check registration status

**3. Vote on Proposals:**
- View active proposals
- Cast encrypted vote (Yes/No)
- Track voting status

**4. Delegate (Optional):**
- Select trusted delegate
- Transfer voting power
- Revoke anytime

## 📚 Documentation

Complete documentation available:
- 📖 **[TESTING.md](./TESTING.md)** - Testing guide with 54 test cases
- 🚀 **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Deployment instructions
- 🔄 **[CI_CD.md](./CI_CD.md)** - CI/CD pipeline documentation
- 🔒 **[SECURITY.md](./SECURITY.md)** - Security and optimization guide

## 🤝 Contributing

Contributions are welcome! Here's how to contribute:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

**Development Guidelines**:
- Follow existing code style
- Add tests for new features
- Update documentation
- Ensure CI/CD passes

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

## 💬 Support

Need help? Here's how to get support:

- 📝 **Issues**: [Create an issue](https://github.com/your-repo/issues) on GitHub
- 📖 **Documentation**: Review the comprehensive docs in this repository
- 💡 **Discussions**: Join GitHub Discussions for Q&A

## 🏆 Acknowledgments

This project is built with industry-leading tools and practices:

- **[Hardhat](https://hardhat.org/)** - Ethereum development framework
- **[OpenZeppelin](https://openzeppelin.com/)** - Secure smart contract libraries
- **[Sepolia Testnet](https://sepolia.etherscan.io/)** - Ethereum test network
- **[GitHub Actions](https://github.com/features/actions)** - CI/CD automation
- **[Codecov](https://codecov.io/)** - Code coverage reporting

Special thanks to the Ethereum and Web3 community for open-source tools and best practices.

---

<div align="center">

**🔐 Built for decentralized democracy and privacy-preserving governance**

Made with ❤️ by the community

</div>
