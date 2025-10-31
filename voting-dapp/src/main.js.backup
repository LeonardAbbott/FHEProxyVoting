/**
 * Privacy Voting DApp - FHEVM SDK Integration Example
 *
 * This example demonstrates a real-world privacy-preserving voting system
 * integrated with the FHEVM SDK for encrypted voting operations.
 *
 * Features:
 * - Wallet connection
 * - Voter registration
 * - Vote delegation
 * - Encrypted voting using FHEVM SDK
 * - Proposal management
 */

import { BrowserProvider } from 'ethers';
import { FhevmClient } from 'fhevm-sdk';
import './style.css';
import { initializeApp } from './app.js';

// Contract configuration
const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS || '0xA52413121E6C22502efACF91714889f85BaA9A88';
const CONTRACT_ABI = [
  'function registerVoter(address voter) external',
  'function createProposal(string calldata description) external returns (uint256)',
  'function delegateVote(address delegate) external',
  'function revokeDelegation() external',
  'function vote(uint256 proposalId, bool isYes, bytes calldata inputProof) external',
  'function getProposal(uint256 proposalId) external view returns (string memory, uint256, bool)',
  'function getDelegation(address voter) external view returns (address, bool)',
  'function hasVoted(uint256 proposalId, address voter) external view returns (bool)',
  'function isRegisteredVoter(address voter) external view returns (bool)',
  'function proposalCount() external view returns (uint256)',
  'function votingPower(address voter) external view returns (uint256)',
];

// Global state
let app = {
  provider: null,
  signer: null,
  account: null,
  contract: null,
  fhevmClient: null,
  isInitialized: false,
};

// Initialize the application
async function init() {
  console.log('🚀 Starting Privacy Voting DApp with FHEVM SDK Integration');

  // Render initial UI
  renderApp();

  // Setup event listeners
  document.getElementById('connect-btn').addEventListener('click', connectWallet);
}

// Connect wallet and initialize FHEVM
async function connectWallet() {
  try {
    if (!window.ethereum) {
      showMessage('❌ MetaMask is required. Please install MetaMask.', 'error');
      return;
    }

    showMessage('🔄 Connecting wallet...');

    const accounts = await window.ethereum.request({
      method: 'eth_requestAccounts'
    });

    // Check network
    const chainId = await window.ethereum.request({ method: 'eth_chainId' });
    if (chainId !== '0xaa36a7') {
      await switchToSepolia();
    }

    // Setup ethers
    app.provider = new BrowserProvider(window.ethereum);
    app.signer = await app.provider.getSigner();
    app.account = accounts[0];

    // Get contract
    const { Contract } = await import('ethers');
    app.contract = new Contract(CONTRACT_ADDRESS, CONTRACT_ABI, app.signer);

    showMessage('🔐 Initializing FHEVM SDK...');

    // Initialize FHEVM SDK
    app.fhevmClient = new FhevmClient({
      provider: app.provider,
      contractAddress: CONTRACT_ADDRESS,
    });

    await app.fhevmClient.initialize();
    app.isInitialized = true;

    showMessage('✅ Wallet connected and FHEVM SDK initialized!', 'success');

    // Load user data
    await loadUserData();

    // Render main app
    initializeApp(app, { showMessage, renderApp });

  } catch (error) {
    console.error('Connection failed:', error);
    showMessage('❌ Failed to connect wallet', 'error');
  }
}

async function switchToSepolia() {
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

async function loadUserData() {
  try {
    const isRegistered = await app.contract.isRegisteredVoter(app.account);
    const delegation = await app.contract.getDelegation(app.account);
    const power = await app.contract.votingPower(app.account);

    app.userData = {
      isRegistered,
      delegation: {
        delegate: delegation[0],
        active: delegation[1],
      },
      votingPower: Number(power),
    };
  } catch (error) {
    console.error('Failed to load user data:', error);
    app.userData = {
      isRegistered: false,
      delegation: { delegate: '', active: false },
      votingPower: 0,
    };
  }
}

function showMessage(msg, type = 'info') {
  const container = document.getElementById('message-container');
  const className = type === 'success' ? 'success' : type === 'error' ? 'error' : 'info';
  container.innerHTML = `<div class="message ${className}">${msg}</div>`;
}

function renderApp() {
  const appDiv = document.getElementById('app');

  if (!app.isInitialized) {
    appDiv.innerHTML = `
      <div class="container">
        <div class="header">
          <h1>🔐 Privacy Voting DApp</h1>
          <p class="subtitle">FHEVM SDK Integration Example</p>
          <p class="description">
            This example demonstrates a real privacy-preserving voting system
            using the FHEVM SDK for encrypted vote operations.
          </p>
        </div>

        <div class="info-box">
          <p><strong>📋 Features:</strong></p>
          <ul>
            <li>✅ Wallet connection with MetaMask</li>
            <li>✅ FHEVM SDK initialization and encryption</li>
            <li>✅ Voter registration on-chain</li>
            <li>✅ Vote delegation with privacy</li>
            <li>✅ Encrypted voting using FHE</li>
            <li>✅ Proposal management</li>
          </ul>
        </div>

        <div class="info-box">
          <p><strong>🌐 Network:</strong> Ethereum Sepolia Testnet</p>
          <p><strong>📜 Contract:</strong> <code>${CONTRACT_ADDRESS}</code></p>
        </div>

        <div id="message-container"></div>

        <div class="button-group">
          <button id="connect-btn" class="btn btn-primary">
            🔗 Connect Wallet & Initialize FHEVM
          </button>
        </div>

        <div class="footer">
          <p>🔧 This example shows integration of the FHEVM SDK with a real voting contract</p>
          <p>🔐 All votes are encrypted using Fully Homomorphic Encryption</p>
        </div>
      </div>
    `;
  }
}

// Start the application
init();

export { app, showMessage, renderApp, loadUserData };
