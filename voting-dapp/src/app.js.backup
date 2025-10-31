/**
 * Main application logic for Privacy Voting DApp
 * Handles voting, delegation, and proposal management using FHEVM SDK
 */

export function initializeApp(app, utils) {
  const { showMessage, renderApp } = utils;

  // Render main application UI
  renderMainUI();

  // Setup event listeners
  setupEventListeners();

  function renderMainUI() {
    const appDiv = document.getElementById('app');

    appDiv.innerHTML = `
      <div class="container">
        <div class="header">
          <h1>🔐 Privacy Voting DApp</h1>
          <p class="subtitle">Connected: <code>${app.account.slice(0, 6)}...${app.account.slice(-4)}</code></p>
        </div>

        <div id="message-container"></div>

        ${renderRegistrationSection()}
        ${renderDelegationSection()}
        ${renderVotingSection()}
        ${renderProposalsSection()}

        <div class="footer">
          <p>🔐 Powered by FHEVM SDK</p>
          <p>All votes are encrypted using Fully Homomorphic Encryption</p>
        </div>
      </div>
    `;
  }

  function renderRegistrationSection() {
    if (!app.userData) return '';

    return `
      <div class="card">
        <h2>📝 Voter Registration</h2>
        <p>Status: ${app.userData.isRegistered ? '✅ Registered' : '⚠️ Not Registered'}</p>
        ${!app.userData.isRegistered ? `
          <button id="register-btn" class="btn btn-primary">
            🎫 Register as Voter
          </button>
        ` : ''}
      </div>
    `;
  }

  function renderDelegationSection() {
    if (!app.userData) return '';

    return `
      <div class="card">
        <h2>🤝 Vote Delegation</h2>
        ${app.userData.delegation.active ? `
          <p class="success">✅ Currently delegated to:</p>
          <p><code>${app.userData.delegation.delegate}</code></p>
          <button id="revoke-btn" class="btn btn-warning">
            🚫 Revoke Delegation
          </button>
        ` : `
          <p>💡 Delegate your voting power to a trusted representative</p>
          <input
            type="text"
            id="delegate-address"
            class="input"
            placeholder="Enter delegate address (0x...)"
          />
          <button id="delegate-btn" class="btn btn-primary">
            🤝 Delegate Vote
          </button>
        `}
      </div>
    `;
  }

  function renderVotingSection() {
    return `
      <div class="card">
        <h2>🗳️ Cast Your Vote</h2>
        <p class="info-box">
          🔐 Your votes are encrypted using the FHEVM SDK before being submitted to the blockchain.
          Vote choices remain private and secure.
        </p>
        <div id="voting-area">
          <button id="load-proposals-btn" class="btn btn-secondary">
            📋 Load Active Proposals
          </button>
        </div>
      </div>
    `;
  }

  function renderProposalsSection() {
    return `
      <div class="card">
        <h2>📊 Proposal Management</h2>
        <input
          type="text"
          id="proposal-desc"
          class="input"
          placeholder="Enter proposal description"
        />
        <button id="create-proposal-btn" class="btn btn-primary">
          ✍️ Create Proposal
        </button>
      </div>
    `;
  }

  function setupEventListeners() {
    // Registration
    const registerBtn = document.getElementById('register-btn');
    if (registerBtn) {
      registerBtn.addEventListener('click', registerVoter);
    }

    // Delegation
    const delegateBtn = document.getElementById('delegate-btn');
    if (delegateBtn) {
      delegateBtn.addEventListener('click', delegateVote);
    }

    const revokeBtn = document.getElementById('revoke-btn');
    if (revokeBtn) {
      revokeBtn.addEventListener('click', revokeDelegation);
    }

    // Proposals
    const loadProposalsBtn = document.getElementById('load-proposals-btn');
    if (loadProposalsBtn) {
      loadProposalsBtn.addEventListener('click', loadProposals);
    }

    const createProposalBtn = document.getElementById('create-proposal-btn');
    if (createProposalBtn) {
      createProposalBtn.addEventListener('click', createProposal);
    }
  }

  async function registerVoter() {
    try {
      showMessage('🔄 Registering as voter...');
      const tx = await app.contract.registerVoter(app.account);
      await tx.wait();
      showMessage('✅ Successfully registered as voter!', 'success');

      // Reload user data and UI
      await loadUserData();
      renderMainUI();
      setupEventListeners();
    } catch (error) {
      console.error('Registration failed:', error);
      showMessage('❌ Registration failed: ' + error.message, 'error');
    }
  }

  async function delegateVote() {
    const delegateAddress = document.getElementById('delegate-address').value;

    if (!delegateAddress || !delegateAddress.startsWith('0x')) {
      showMessage('⚠️ Please enter a valid delegate address', 'error');
      return;
    }

    try {
      showMessage('🔄 Delegating vote...');
      const tx = await app.contract.delegateVote(delegateAddress);
      await tx.wait();
      showMessage('✅ Vote successfully delegated!', 'success');

      // Reload user data and UI
      await loadUserData();
      renderMainUI();
      setupEventListeners();
    } catch (error) {
      console.error('Delegation failed:', error);
      showMessage('❌ Delegation failed: ' + error.message, 'error');
    }
  }

  async function revokeDelegation() {
    try {
      showMessage('🔄 Revoking delegation...');
      const tx = await app.contract.revokeDelegation();
      await tx.wait();
      showMessage('✅ Delegation revoked successfully!', 'success');

      // Reload user data and UI
      await loadUserData();
      renderMainUI();
      setupEventListeners();
    } catch (error) {
      console.error('Revocation failed:', error);
      showMessage('❌ Revocation failed: ' + error.message, 'error');
    }
  }

  async function loadProposals() {
    try {
      showMessage('🔄 Loading proposals...');

      const count = await app.contract.proposalCount();
      const proposals = [];

      for (let i = 0; i < Number(count); i++) {
        const proposal = await app.contract.getProposal(i);
        const hasVoted = await app.contract.hasVoted(i, app.account);

        proposals.push({
          id: i,
          description: proposal[0],
          deadline: Number(proposal[1]),
          active: proposal[2],
          hasVoted,
        });
      }

      renderProposalsList(proposals);
      showMessage(`✅ Loaded ${proposals.length} proposals`, 'success');
    } catch (error) {
      console.error('Failed to load proposals:', error);
      showMessage('❌ Failed to load proposals: ' + error.message, 'error');
    }
  }

  function renderProposalsList(proposals) {
    const votingArea = document.getElementById('voting-area');

    if (proposals.length === 0) {
      votingArea.innerHTML = '<p>No proposals available</p>';
      return;
    }

    let html = '<div class="proposals-list">';

    proposals.forEach(proposal => {
      html += `
        <div class="proposal-item ${proposal.hasVoted ? 'voted' : ''}">
          <h3>Proposal #${proposal.id}</h3>
          <p>${proposal.description}</p>
          <p class="proposal-meta">
            Deadline: ${new Date(proposal.deadline * 1000).toLocaleDateString()} |
            Status: ${proposal.active ? '🟢 Active' : '🔴 Closed'}
          </p>
          ${proposal.active && !proposal.hasVoted ? `
            <div class="vote-buttons">
              <button class="btn btn-success" onclick="window.vote(${proposal.id}, true)">
                ✅ Vote YES
              </button>
              <button class="btn btn-danger" onclick="window.vote(${proposal.id}, false)">
                ❌ Vote NO
              </button>
            </div>
          ` : proposal.hasVoted ? `
            <p class="voted-label">✅ You have voted</p>
          ` : ''}
        </div>
      `;
    });

    html += '</div>';
    votingArea.innerHTML = html;
  }

  // Global vote function (accessible from HTML)
  window.vote = async function(proposalId, isYes) {
    try {
      showMessage('🔐 Encrypting your vote using FHEVM SDK...');

      // Encrypt the vote using FHEVM SDK
      const encryptedVote = app.fhevmClient.encryptBool(isYes);

      showMessage('📤 Submitting encrypted vote to blockchain...');

      // Submit to contract
      const tx = await app.contract.vote(proposalId, isYes, encryptedVote);
      await tx.wait();

      showMessage('✅ Vote successfully submitted and encrypted on-chain!', 'success');

      // Reload proposals
      await loadProposals();
    } catch (error) {
      console.error('Voting failed:', error);
      showMessage('❌ Voting failed: ' + error.message, 'error');
    }
  };

  async function createProposal() {
    const description = document.getElementById('proposal-desc').value;

    if (!description) {
      showMessage('⚠️ Please enter a proposal description', 'error');
      return;
    }

    try {
      showMessage('🔄 Creating proposal...');
      const tx = await app.contract.createProposal(description);
      await tx.wait();
      showMessage('✅ Proposal created successfully!', 'success');

      // Clear input and reload proposals
      document.getElementById('proposal-desc').value = '';
      await loadProposals();
    } catch (error) {
      console.error('Failed to create proposal:', error);
      showMessage('❌ Failed to create proposal: ' + error.message, 'error');
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
    }
  }
}
