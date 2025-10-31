/**
 * Voter Registration Component
 * Handles voter registration on-chain
 */

function VoterRegistration({ userData, contract, account, showMessage, refreshUserData }) {
  if (!userData) return null;

  const handleRegister = async () => {
    try {
      showMessage('Registering as voter...');
      const tx = await contract.registerVoter(account);
      await tx.wait();
      showMessage('Successfully registered as voter!', 'success');
      await refreshUserData();
    } catch (error) {
      console.error('Registration failed:', error);
      showMessage('Registration failed: ' + error.message, 'error');
    }
  };

  return (
    <div className="card">
      <h2>Voter Registration</h2>
      <p>Status: {userData.isRegistered ? 'Registered' : 'Not Registered'}</p>
      {!userData.isRegistered && (
        <button onClick={handleRegister} className="btn btn-primary">
          Register as Voter
        </button>
      )}
    </div>
  );
}

export default VoterRegistration;
