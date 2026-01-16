/**
 * Check-In Component
 * Allows users to view and interact with nearby check-ins
 */

import React, { useState, useEffect } from 'react';
import checkInService from '../services/checkInService';
import ProtectedButton from './ProtectedButton';
import './CheckInCard.css';

const CheckInCard = ({ checkIn, onLike, onMessage, onViewProfile }) => {
  const [isLiked, setIsLiked] = useState(false);
  const [likeCount, setLikeCount] = useState(checkIn.likes || 0);
  const [showMessage, setShowMessage] = useState(false);
  const [message, setMessage] = useState('');
  const [sending, setSending] = useState(false);

  const handleLike = async () => {
    try {
      if (isLiked) {
        await checkInService.unlikeCheckIn(checkIn.id, checkIn.user.id);
        setLikeCount(likeCount - 1);
        setIsLiked(false);
      } else {
        await checkInService.likeCheckIn(checkIn.id, checkIn.user.id);
        setLikeCount(likeCount + 1);
        setIsLiked(true);
      }
      if (onLike) onLike(checkIn.id, !isLiked);
    } catch (error) {
      console.error('Error liking check-in:', error);
    }
  };

  const handleSendMessage = async () => {
    if (!message.trim()) return;

    try {
      setSending(true);
      await checkInService.sendMessage(checkIn.id, checkIn.user.id, message);
      setMessage('');
      setShowMessage(false);
      if (onMessage) onMessage(checkIn.id, message);
    } catch (error) {
      console.error('Error sending message:', error);
    } finally {
      setSending(false);
    }
  };

  const getCheckInIcon = (type) => {
    const icons = {
      Hotel: '??',
      Resort: '???',
      Vacation: '??',
      School: '??',
      University: '??',
      Workplace: '??',
      Conference: '??',
      Festival: '??',
      Event: '??',
      Travel: '??',
      Retreat: '???',
      Staycation: '??',
      'Study Abroad': '??',
      'Business Trip': '??',
      Other: '??',
    };
    return icons[type] || '??';
  };

  const getStatusColor = (status) => {
    const colors = {
      'Checked In': '#4caf50',
      'Interested': '#2196f3',
      'Looking to Meet': '#ff9800',
      'Casual': '#9c27b0',
      'Social': '#00bcd4',
    };
    return colors[status] || '#757575';
  };

  return (
    <div className="check-in-card">
      {/* Check-In Header */}
      <div className="check-in-header">
        <div className="check-in-type">
          <span className="check-in-icon">{getCheckInIcon(checkIn.type)}</span>
          <div className="check-in-location">
            <h4 className="check-in-title">{checkIn.location.name}</h4>
            <p className="check-in-city">{checkIn.location.city}</p>
          </div>
        </div>
        <span className="check-in-time">{checkIn.timeAgo}</span>
      </div>

      {/* User Profile Section */}
      <div className="check-in-user">
        <img
          src={checkIn.displayPhoto}
          alt={checkIn.displayName}
          className="user-avatar"
          onClick={() => onViewProfile && onViewProfile(checkIn.user.id)}
        />
        <div className="user-info">
          <h3 className="user-name" onClick={() => onViewProfile && onViewProfile(checkIn.user.id)}>
            {checkIn.displayName}, {checkIn.displayAge}
          </h3>
          <p className="user-bio">{checkIn.description}</p>

          {/* Status Badge */}
          <div className="status-badge" style={{ backgroundColor: getStatusColor(checkIn.status) }}>
            {checkIn.status}
          </div>
        </div>
      </div>

      {/* Check-In Photos */}
      {checkIn.photos && checkIn.photos.length > 0 && (
        <div className="check-in-photos">
          {checkIn.photos.slice(0, 3).map((photo, index) => (
            <img
              key={index}
              src={photo}
              alt={`Check-in ${index + 1}`}
              className="photo-thumbnail"
            />
          ))}
          {checkIn.photos.length > 3 && (
            <div className="photo-more">+{checkIn.photos.length - 3}</div>
          )}
        </div>
      )}

      {/* Interests Tags */}
      {checkIn.interests && checkIn.interests.length > 0 && (
        <div className="interests-section">
          <div className="interests-tags">
            {checkIn.interests.slice(0, 4).map((interest) => (
              <span key={interest} className="interest-tag">
                {interest}
              </span>
            ))}
            {checkIn.interests.length > 4 && (
              <span className="interest-more">+{checkIn.interests.length - 4}</span>
            )}
          </div>
        </div>
      )}

      {/* Check-In Meta */}
      <div className="check-in-meta">
        <span className="meta-item">
          ?? {checkIn.viewers || 0} views
        </span>
        <span className="meta-item">
          ?? {likeCount} likes
        </span>
        {checkIn.distance && (
          <span className="meta-item">
            ?? {checkIn.distance.toFixed(1)} km away
          </span>
        )}
      </div>

      {/* Action Buttons */}
      <div className="check-in-actions">
        <ProtectedButton
          feature="messages"
          onClick={() => setShowMessage(!showMessage)}
          className="message-btn"
          variant="secondary"
        >
          ?? Message
        </ProtectedButton>
        <button
          className={`like-btn ${isLiked ? 'liked' : ''}`}
          onClick={handleLike}
          title={isLiked ? 'Unlike' : 'Like'}
        >
          {isLiked ? '??' : '??'} Like
        </button>
        <ProtectedButton
          feature="videoCalls"
          onClick={() => {}}
          className="video-btn"
          variant="outline"
        >
          ?? Video
        </ProtectedButton>
      </div>

      {/* Message Input */}
      {showMessage && (
        <div className="message-input-section">
          <textarea
            className="message-input"
            placeholder="Say hello..."
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            rows="3"
          />
          <div className="message-actions">
            <button
              className="send-btn"
              onClick={handleSendMessage}
              disabled={!message.trim() || sending}
            >
              {sending ? 'Sending...' : 'Send'}
            </button>
            <button
              className="cancel-btn"
              onClick={() => setShowMessage(false)}
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      {/* Verification Badge */}
      {checkIn.user.isVerified && (
        <div className="verified-badge">? Verified</div>
      )}
    </div>
  );
};

export default CheckInCard;
