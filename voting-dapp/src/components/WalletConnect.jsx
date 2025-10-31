/**
 * Wallet Connect Component
 * Initial screen for connecting wallet and initializing FHEVM
 */

import MessageDisplay from './MessageDisplay';

function WalletConnect({ onConnect, contractAddress, message }) {
  return (
    <div className="container">
      <div className="header">
        <h1>Privacy Voting DApp</h1>
        <p className="subtitle">FHEVM SDK Integration Example</p>
        <p className="description">
          This example demonstrates a real privacy-preserving voting system
          using the FHEVM SDK for encrypted vote operations.
        </p>
      </div>

      <div className="info-box">
        <p><strong>Features:</strong></p>
        <ul>
          <li>Wallet connection with MetaMask</li>
          <li>FHEVM SDK initialization and encryption</li>
          <li>Voter registration on-chain</li>
          <li>Vote delegation with privacy</li>
          <li>Encrypted voting using FHE</li>
          <li>Proposal management</li>
        </ul>
      </div>

      <div className="info-box">
        <p><strong>Network:</strong> Ethereum Sepolia Testnet</p>
        <p><strong>Contract:</strong> <code>{contractAddress}</code></p>
      </div>

      <MessageDisplay message={message} />

      <div className="button-group">
        <button onClick={onConnect} className="btn btn-primary">
          Connect Wallet & Initialize FHEVM
        </button>
      </div>

      <div className="footer">
        <p>This example shows integration of the FHEVM SDK with a real voting contract</p>
        <p>All votes are encrypted using Fully Homomorphic Encryption</p>
      </div>
    </div>
  );
}

export default WalletConnect;
