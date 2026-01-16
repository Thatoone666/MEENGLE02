/**
 * Messaging Interface Component
 * Full messaging conversation view for Flame+ users
 */

import React, { useState, useEffect, useRef } from 'react';
import directMessagingService from '../services/directMessagingService';
import ProtectedButton from './ProtectedButton';
import './MessagingInterface.css';

const MessagingInterface = ({ recipientId, recipient }) => {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [showOptions, setShowOptions] = useState(false);
  const [isBlocked, setIsBlocked] = useState(false);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    loadConversation();
    markAsRead();
  }, [recipientId]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const loadConversation = async () => {
    try {
      setLoading(true);
      const conversation = await directMessagingService.getConversation(
        recipientId,
        50
      );
      setMessages(conversation);
    } catch (error) {
      console.error('Error loading conversation:', error);
    } finally {
      setLoading(false);
    }
  };

  const markAsRead = async () => {
    try {
      await directMessagingService.markConversationAsRead(recipientId);
    } catch (error) {
      console.error('Error marking as read:', error);
    }
  };

  const handleSendMessage = async () => {
    if (!newMessage.trim() || isBlocked) return;

    try {
      setSending(true);
      const sentMessage = await directMessagingService.sendMessage(
        recipientId,
        {
          content: newMessage,
          type: 'text',
        }
      );

      setMessages([...messages, sentMessage]);
      setNewMessage('');
    } catch (error) {
      console.error('Error sending message:', error);
    } finally {
      setSending(false);
    }
  };

  const handleBlockUser = async () => {
    try {
      await directMessagingService.blockUser(recipientId);
      setIsBlocked(true);
      setShowOptions(false);
    } catch (error) {
      console.error('Error blocking user:', error);
    }
  };

  const handleReportUser = async () => {
    const reason = prompt(
      'What is the reason for reporting this user?',
      'Harassment'
    );
    if (!reason) return;

    const description = prompt('Provide additional details:');

    try {
      await directMessagingService.reportUser(
        recipientId,
        reason,
        description || ''
      );
      alert('User reported successfully');
      setShowOptions(false);
    } catch (error) {
      console.error('Error reporting user:', error);
    }
  };

  const handleVideoCall = async () => {
    try {
      await directMessagingService.requestVideoCall(recipientId);
      setShowOptions(false);
    } catch (error) {
      console.error('Error requesting video call:', error);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  const currentUserId = localStorage.getItem('userId');

  return (
    <div className="messaging-interface">
      {/* Header */}
      <div className="msg-header">
        <div className="msg-user-info">
          <img src={recipient?.photo} alt={recipient?.name} className="msg-avatar" />
          <div className="msg-info">
            <h3 className="msg-name">
              {recipient?.name}, {recipient?.age}
            </h3>
            <p className="msg-status">
              {recipient?.lastSeen
                ? `Active ${directMessagingService.formatMessageTime(recipient.lastSeen)}`
                : 'Offline'}
            </p>
          </div>
        </div>

        <div className="msg-actions">
          <ProtectedButton
            feature="videoCalls"
            onClick={handleVideoCall}
            variant="secondary"
          >
            ??
          </ProtectedButton>

          <div className="msg-options">
            <button
              className="msg-options-btn"
              onClick={() => setShowOptions(!showOptions)}
            >
              ?
            </button>

            {showOptions && (
              <div className="msg-dropdown">
                <button onClick={() => {}}>?? Share Activity</button>
                <button onClick={handleVideoCall}>?? Video Call</button>
                <button onClick={handleBlockUser}>?? Block User</button>
                <button onClick={handleReportUser} className="danger">
                  ?? Report User
                </button>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Messages */}
      <div className="msg-body">
        {loading ? (
          <div className="msg-loading">Loading conversation...</div>
        ) : messages.length === 0 ? (
          <div className="msg-empty">
            <div className="empty-icon">??</div>
            <p>Start the conversation!</p>
            <small>Be genuine and respectful</small>
          </div>
        ) : (
          <>
            {messages.map((message) => (
              <div
                key={message.id}
                className={`msg-item ${
                  message.senderId === currentUserId ? 'sent' : 'received'
                }`}
              >
                <div className="msg-content">
                  <div className="msg-text">{message.content}</div>
                  <div className="msg-time">
                    {directMessagingService.formatMessageTime(
                      message.createdAt
                    )}
                  </div>
                  {message.senderId === currentUserId && (
                    <div className="msg-status-icon">
                      {message.status === 'read' && '??'}
                      {message.status === 'delivered' && '?'}
                      {message.status === 'sent' && '?'}
                    </div>
                  )}
                </div>
              </div>
            ))}
            <div ref={messagesEndRef} />
          </>
        )}
      </div>

      {/* Input Area */}
      {isBlocked ? (
        <div className="msg-blocked">
          ?? You have blocked this user. Unblock to message.
        </div>
      ) : (
        <div className="msg-footer">
          <textarea
            className="msg-input"
            placeholder="Type a message..."
            value={newMessage}
            onChange={(e) => setNewMessage(e.target.value)}
            onKeyPress={handleKeyPress}
            rows="1"
          />
          <button
            className="msg-send-btn"
            onClick={handleSendMessage}
            disabled={!newMessage.trim() || sending}
          >
            {sending ? '...' : '?'}
          </button>
        </div>
      )}
    </div>
  );
};

export default MessagingInterface;
