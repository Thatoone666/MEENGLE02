/**
 * Quick Message Modal Component
 * Appears on profiles/swipes/check-ins for direct messaging
 */

import React, { useState } from 'react';
import directMessagingService from '../services/directMessagingService';
import './QuickMessageModal.css';

const QuickMessageModal = ({
  isOpen,
  recipient,
  context, // 'profile', 'swipe', 'check_in', 'activity'
  onClose,
  onSent,
}) => {
  const [message, setMessage] = useState('');
  const [sending, setSending] = useState(false);
  const [error, setError] = useState(null);
  const [icebreakers] = useState([
    '?? Hey, how are you?',
    '?? I think we\'d get along great!',
    '?? Interested in grabbing coffee?',
    '?? Want to join me for a workout?',
    '?? Have you seen this new movie?',
    '?? Where are you traveling to next?',
    '?? What\'s your favorite music?',
  ]);

  if (!isOpen || !recipient) return null;

  const handleSendMessage = async () => {
    if (!message.trim()) {
      setError('Message cannot be empty');
      return;
    }

    try {
      setSending(true);
      setError(null);

      await directMessagingService.sendMessage(recipient.id, {
        content: message,
        type: 'text',
        context,
      });

      setMessage('');
      if (onSent) onSent();

      // Close modal after short delay
      setTimeout(() => {
        onClose();
      }, 500);
    } catch (err) {
      setError('Failed to send message. Please try again.');
      console.error('Error sending message:', err);
    } finally {
      setSending(false);
    }
  };

  const handleIcebreakerClick = (icebreaker) => {
    setMessage(icebreaker);
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  return (
    <div className="quick-message-overlay">
      <div className="quick-message-modal">
        {/* Header */}
        <div className="qm-header">
          <img src={recipient.photo} alt={recipient.name} className="qm-avatar" />
          <div className="qm-info">
            <h3 className="qm-name">
              {recipient.name}, {recipient.age}
            </h3>
            <p className="qm-status">{recipient.status || 'Online'}</p>
          </div>
          <button className="qm-close" onClick={onClose}>
            ?
          </button>
        </div>

        {/* Context Label */}
        <div className="qm-context">
          {context === 'profile' && '?? Sending a message to their profile'}
          {context === 'swipe' && '?? They caught your attention!'}
          {context === 'check_in' && '?? Connect from check-in'}
          {context === 'activity' && '?? Invite to activity'}
        </div>

        {/* Message Input */}
        <textarea
          className="qm-input"
          placeholder="Write a message..."
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          onKeyPress={handleKeyPress}
          rows="4"
        />

        {/* Character Count */}
        <div className="qm-count">
          {message.length}/500
        </div>

        {/* Icebreakers */}
        <div className="qm-icebreakers">
          <p className="ib-label">Need inspiration? Try:</p>
          <div className="ib-list">
            {icebreakers.map((icebreaker, index) => (
              <button
                key={index}
                className="ib-button"
                onClick={() => handleIcebreakerClick(icebreaker)}
                title="Click to use this message"
              >
                {icebreaker}
              </button>
            ))}
          </div>
        </div>

        {/* Error Message */}
        {error && <div className="qm-error">{error}</div>}

        {/* Action Buttons */}
        <div className="qm-actions">
          <button className="qm-cancel" onClick={onClose}>
            Cancel
          </button>
          <button
            className="qm-send"
            onClick={handleSendMessage}
            disabled={!message.trim() || sending}
          >
            {sending ? 'Sending...' : 'Send Message'}
          </button>
        </div>

        {/* Safety Tip */}
        <div className="qm-tip">
          ?? Be genuine and respectful. Respectful messages get better responses!
        </div>
      </div>
    </div>
  );
};

export default QuickMessageModal;
