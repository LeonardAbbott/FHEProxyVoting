/**
 * Vote Delegation Component
 * Handles vote delegation to trusted representatives
 */

import { useState } from 'react';

function VoteDelegation({ userData, contract, showMessage, refreshUserData }) {
  const [delegateAddress, setDelegateAddress] = useState('');

  if (!userData) return null;

  const handleDelegate = async () => {
    if (!delegateAddress || !delegateAddress.startsWith('0x')) {
      showMessage('Please enter a valid delegate address', 'error');
      return;
    }

    try {
      showMessage('Delegating vote...');
      const tx = await contract.delegateVote(delegateAddress);
      await tx.wait();
      showMessage('Vote successfully delegated!', 'success');
      setDelegateAddress('');
      await refreshUserData();
    } catch (error) {
      console.error('Delegation failed:', error);
      showMessage('Delegation failed: ' + error.message, 'error');
    }
  };

  const handleRevoke = async () => {
    try {
      showMessage('Revoking delegation...');
      const tx = await contract.revokeDelegation();
      await tx.wait();
      showMessage('Delegation revoked successfully!', 'success');
      await refreshUserData();
    } catch (error) {
      console.error('Revocation failed:', error);
      showMessage('Revocation failed: ' + error.message, 'error');
    }
  };

  return (
    <div className="card">
      <h2>Vote Delegation</h2>
      {userData.delegation.active ? (
        <>
          <p className="success">Currently delegated to:</p>
          <p><code>{userData.delegation.delegate}</code></p>
          <button onClick={handleRevoke} className="btn btn-warning">
            Revoke Delegation
          </button>
        </>
      ) : (
        <>
          <p>Delegate your voting power to a trusted representative</p>
          <input
            type="text"
            value={delegateAddress}
            onChange={(e) => setDelegateAddress(e.target.value)}
            className="input"
            placeholder="Enter delegate address (0x...)"
          />
          <button onClick={handleDelegate} className="btn btn-primary">
            Delegate Vote
          </button>
        </>
      )}
    </div>
  );
}

export default VoteDelegation;
