/**
 * Voting Section Component
 * Handles loading and displaying proposals with voting functionality
 */

import { useState } from 'react';
import ProposalsList from './ProposalsList';

function VotingSection({ contract, account, fhevmClient, showMessage }) {
  const [proposals, setProposals] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  const loadProposals = async () => {
    try {
      setIsLoading(true);
      showMessage('Loading proposals...');

      const count = await contract.proposalCount();
      const loadedProposals = [];

      for (let i = 0; i < Number(count); i++) {
        const proposal = await contract.getProposal(i);
        const hasVoted = await contract.hasVoted(i, account);

        loadedProposals.push({
          id: i,
          description: proposal[0],
          deadline: Number(proposal[1]),
          active: proposal[2],
          hasVoted,
        });
      }

      setProposals(loadedProposals);
      showMessage(`Loaded ${loadedProposals.length} proposals`, 'success');
    } catch (error) {
      console.error('Failed to load proposals:', error);
      showMessage('Failed to load proposals: ' + error.message, 'error');
    } finally {
      setIsLoading(false);
    }
  };

  const handleVote = async (proposalId, isYes) => {
    try {
      showMessage('Encrypting your vote using FHEVM SDK...');

      // Encrypt the vote using FHEVM SDK
      const encryptedVote = fhevmClient.encryptBool(isYes);

      showMessage('Submitting encrypted vote to blockchain...');

      // Submit to contract
      const tx = await contract.vote(proposalId, isYes, encryptedVote);
      await tx.wait();

      showMessage('Vote successfully submitted and encrypted on-chain!', 'success');

      // Reload proposals
      await loadProposals();
    } catch (error) {
      console.error('Voting failed:', error);
      showMessage('Voting failed: ' + error.message, 'error');
    }
  };

  return (
    <div className="card">
      <h2>Cast Your Vote</h2>
      <p className="info-box">
        Your votes are encrypted using the FHEVM SDK before being submitted to the blockchain.
        Vote choices remain private and secure.
      </p>
      <div id="voting-area">
        {proposals.length === 0 ? (
          <button
            onClick={loadProposals}
            className="btn btn-secondary"
            disabled={isLoading}
          >
            {isLoading ? 'Loading...' : 'Load Active Proposals'}
          </button>
        ) : (
          <ProposalsList proposals={proposals} onVote={handleVote} />
        )}
      </div>
    </div>
  );
}

export default VotingSection;
