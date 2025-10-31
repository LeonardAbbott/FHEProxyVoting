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

import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './components/App';
import './style.css';

ReactDOM.createRoot(document.getElementById('app')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
