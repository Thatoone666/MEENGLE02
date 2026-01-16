/**
 * Messaging Slide-In Panel - REDESIGNED
 * Replace modal with slide-in panel for better context
 * PHASE 4: Messaging Panel Redesign
 */

import React, { useState, useEffect, useRef } from 'react';
import directMessagingService from '../services/directMessagingService';
import ProtectedButton from './ProtectedButton';
import './MessagingSlidePanel.css';

const MessagingSlidePanel = ({ isOpen, recipient, onClose }) => {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef(null);
  const panelRef = useRef(null);

  useEffect(() => {
    if (isOpen && recipient) {
      loadMessages();
    }
  }, [isOpen, recipient]);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const loadMessages = async () => {
    try {
      setLoading(true);
      const conversation = await directMessagingService.getConversation(
        recipient.id,
        50
      );
      setMessages(conversation);
    } catch (error) {
      console.error('Error loading messages:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSendMessage = async () => {
    if (!newMessage.trim()) return;

    try {
      setSending(true);
      const sentMessage = await directMessagingService.sendMessage(
        recipient.id,
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

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  if (!isOpen || !recipient) return null;

  return (
    <>
      {/* Overlay */}
      <div className="messaging-overlay" onClick={onClose} />

      {/* Slide Panel */}
      <div className="messaging-slide-panel" ref={panelRef}>
        {/* Header */}
        <div className="slide-header">
          <div className="header-user">
            <img
              src={recipient.photo}
              alt={recipient.name}
              className="header-avatar"
            />
            <div className="header-info">
              <h3>{recipient.name}, {recipient.age}</h3>
              <p className="online-status">Active now</p>
            </div>
          </div>

          {/* Header Actions */}
          <div className="header-actions">
            <ProtectedButton
              feature="videoCalls"
              onClick={() => {}}
              variant="ghost"
              className="action-icon"
            >
              ??
            </ProtectedButton>
            <button className="close-btn" onClick={onClose}>
              ?
            </button>
          </div>
        </div>

        {/* Messages */}
        <div className="messages-container">
          {loading ? (
            <div className="messages-loading">Loading conversation...</div>
          ) : messages.length === 0 ? (
            <div className="messages-empty">
              <div className="empty-icon">??</div>
              <p>Start the conversation!</p>
            </div>
          ) : (
            <>
              {messages.map((message) => (
                <div
                  key={message.id}
                  className={`message-bubble ${
                    message.isOwn ? 'sent' : 'received'
                  }`}
                >
                  <div className="bubble-content">
                    {message.content}
                  </div>
                  <div className="bubble-time">
                    {directMessagingService.formatMessageTime(
                      message.createdAt
                    )}
                  </div>
                </div>
              ))}
              <div ref={messagesEndRef} />
            </>
          )}
        </div>

        {/* Input */}
        <div className="slide-footer">
          <div className="input-wrapper">
            <textarea
              className="message-textarea"
              placeholder="Type a message..."
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={handleKeyPress}
              rows="1"
            />
            <button
              className="send-btn"
              onClick={handleSendMessage}
              disabled={!newMessage.trim() || sending}
            >
              {sending ? '...' : '?'}
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default MessagingSlidePanel;
