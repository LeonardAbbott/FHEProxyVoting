/**
 * Proposals List Component
 * Displays list of proposals with voting buttons
 */

function ProposalsList({ proposals, onVote }) {
  if (proposals.length === 0) {
    return <p>No proposals available</p>;
  }

  return (
    <div className="proposals-list">
      {proposals.map((proposal) => (
        <div
          key={proposal.id}
          className={`proposal-item ${proposal.hasVoted ? 'voted' : ''}`}
        >
          <h3>Proposal #{proposal.id}</h3>
          <p>{proposal.description}</p>
          <p className="proposal-meta">
            Deadline: {new Date(proposal.deadline * 1000).toLocaleDateString()} |
            Status: {proposal.active ? 'Active' : 'Closed'}
          </p>
          {proposal.active && !proposal.hasVoted ? (
            <div className="vote-buttons">
              <button
                className="btn btn-success"
                onClick={() => onVote(proposal.id, true)}
              >
                Vote YES
              </button>
              <button
                className="btn btn-danger"
                onClick={() => onVote(proposal.id, false)}
              >
                Vote NO
              </button>
            </div>
          ) : proposal.hasVoted ? (
            <p className="voted-label">You have voted</p>
          ) : null}
        </div>
      ))}
    </div>
  );
}

export default ProposalsList;
