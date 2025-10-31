/**
 * Main App Component for Privacy Voting DApp
 * React-based implementation with FHEVM SDK integration
 */

import { useState, useEffect } from 'react';
import { BrowserProvider, Contract } from 'ethers';
import { FhevmClient } from 'fhevm-sdk';
import WalletConnect from './WalletConnect';
import VoterRegistration from './VoterRegistration';
import VoteDelegation from './VoteDelegation';
import VotingSection from './VotingSection';
import ProposalManagement from './ProposalManagement';
import MessageDisplay from './MessageDisplay';

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

function App() {
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);
  const [fhevmClient, setFhevmClient] = useState(null);
  const [isInitialized, setIsInitialized] = useState(false);
  const [userData, setUserData] = useState(null);
  const [message, setMessage] = useState({ text: '', type: 'info' });

  // Load user data from contract
  const loadUserData = async (contractInstance, userAccount) => {
    try {
      const isRegistered = await contractInstance.isRegisteredVoter(userAccount);
      const delegation = await contractInstance.getDelegation(userAccount);
      const power = await contractInstance.votingPower(userAccount);

      setUserData({
        isRegistered,
        delegation: {
          delegate: delegation[0],
          active: delegation[1],
        },
        votingPower: Number(power),
      });
    } catch (error) {
      console.error('Failed to load user data:', error);
      setUserData({
        isRegistered: false,
        delegation: { delegate: '', active: false },
        votingPower: 0,
      });
    }
  };

  // Connect wallet and initialize FHEVM
  const connectWallet = async () => {
    try {
      if (!window.ethereum) {
        showMessage('MetaMask is required. Please install MetaMask.', 'error');
        return;
      }

      showMessage('Connecting wallet...');

      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      });

      // Check network
      const chainId = await window.ethereum.request({ method: 'eth_chainId' });
      if (chainId !== '0xaa36a7') {
        await switchToSepolia();
      }

      // Setup ethers
      const web3Provider = new BrowserProvider(window.ethereum);
      const web3Signer = await web3Provider.getSigner();
      const userAccount = accounts[0];

      setProvider(web3Provider);
      setSigner(web3Signer);
      setAccount(userAccount);

      // Get contract
      const contractInstance = new Contract(CONTRACT_ADDRESS, CONTRACT_ABI, web3Signer);
      setContract(contractInstance);

      showMessage('Initializing FHEVM SDK...');

      // Initialize FHEVM SDK
      const client = new FhevmClient({
        provider: web3Provider,
        contractAddress: CONTRACT_ADDRESS,
      });

      await client.initialize();
      setFhevmClient(client);
      setIsInitialized(true);

      showMessage('Wallet connected and FHEVM SDK initialized!', 'success');

      // Load user data
      await loadUserData(contractInstance, userAccount);

    } catch (error) {
      console.error('Connection failed:', error);
      showMessage('Failed to connect wallet: ' + error.message, 'error');
    }
  };

  const switchToSepolia = async () => {
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
  };

  const showMessage = (text, type = 'info') => {
    setMessage({ text, type });
  };

  const refreshUserData = async () => {
    if (contract && account) {
      await loadUserData(contract, account);
    }
  };

  if (!isInitialized) {
    return (
      <WalletConnect
        onConnect={connectWallet}
        contractAddress={CONTRACT_ADDRESS}
        message={message}
      />
    );
  }

  return (
    <div className="container">
      <div className="header">
        <h1>Privacy Voting DApp</h1>
        <p className="subtitle">
          Connected: <code>{account.slice(0, 6)}...{account.slice(-4)}</code>
        </p>
      </div>

      <MessageDisplay message={message} />

      <VoterRegistration
        userData={userData}
        contract={contract}
        account={account}
        showMessage={showMessage}
        refreshUserData={refreshUserData}
      />

      <VoteDelegation
        userData={userData}
        contract={contract}
        showMessage={showMessage}
        refreshUserData={refreshUserData}
      />

      <VotingSection
        contract={contract}
        account={account}
        fhevmClient={fhevmClient}
        showMessage={showMessage}
      />

      <ProposalManagement
        contract={contract}
        showMessage={showMessage}
      />

      <div className="footer">
        <p>Powered by FHEVM SDK</p>
        <p>All votes are encrypted using Fully Homomorphic Encryption</p>
      </div>
    </div>
  );
}

export default App;
