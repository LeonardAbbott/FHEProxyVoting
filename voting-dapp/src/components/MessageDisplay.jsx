/**
 * Message Display Component
 * Shows status messages to the user
 */

function MessageDisplay({ message }) {
  if (!message || !message.text) return null;

  const className = message.type === 'success' ? 'success' : message.type === 'error' ? 'error' : 'info';

  return (
    <div id="message-container">
      <div className={`message ${className}`}>{message.text}</div>
    </div>
  );
}

export default MessageDisplay;
