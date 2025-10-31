/**
 * Proposal Management Component
 * Handles creation of new proposals
 */

import { useState } from 'react';

function ProposalManagement({ contract, showMessage }) {
  const [description, setDescription] = useState('');
  const [isCreating, setIsCreating] = useState(false);

  const handleCreateProposal = async () => {
    if (!description) {
      showMessage('Please enter a proposal description', 'error');
      return;
    }

    try {
      setIsCreating(true);
      showMessage('Creating proposal...');
      const tx = await contract.createProposal(description);
      await tx.wait();
      showMessage('Proposal created successfully!', 'success');
      setDescription('');
    } catch (error) {
      console.error('Failed to create proposal:', error);
      showMessage('Failed to create proposal: ' + error.message, 'error');
    } finally {
      setIsCreating(false);
    }
  };

  return (
    <div className="card">
      <h2>Proposal Management</h2>
      <input
        type="text"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
        className="input"
        placeholder="Enter proposal description"
        disabled={isCreating}
      />
      <button
        onClick={handleCreateProposal}
        className="btn btn-primary"
        disabled={isCreating}
      >
        {isCreating ? 'Creating...' : 'Create Proposal'}
      </button>
    </div>
  );
}

export default ProposalManagement;
