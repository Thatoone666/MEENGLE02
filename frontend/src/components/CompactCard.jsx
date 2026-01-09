/**
 * Compact Card Component - REDESIGNED
 * Image-first design with progressive disclosure
 * PHASE 4: Better Card Layouts
 */

import React, { useState } from 'react';
import './CompactCard.css';

const CompactCard = ({ type, data, onAction }) => {
  const [showDetails, setShowDetails] = useState(false);

  // Render based on card type
  if (type === 'profile') {
    return <ProfileCard data={data} onAction={onAction} />;
  } else if (type === 'checkin') {
    return <CheckInCompactCard data={data} onAction={onAction} />;
  } else if (type === 'activity') {
    return <ActivityCompactCard data={data} onAction={onAction} />;
  }

  return null;
};

const ProfileCard = ({ data, onAction }) => {
  return (
    <div className="compact-card profile-card">
      {/* Image */}
      <div className="card-image">
        <img src={data.photos[0]} alt={data.name} />
        <div className="card-info-overlay">
          <h3>{data.name}, {data.age}</h3>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="card-quick-actions">
        <button className="action-btn pass" onClick={() => onAction('pass', data.id)}>
          ?
        </button>
        <button className="action-btn like" onClick={() => onAction('like', data.id)}>
          ??
        </button>
      </div>

      {/* Details on Tap */}
      <div className="card-summary">
        <p className="bio-preview">{data.bio?.substring(0, 40)}...</p>
        <div className="tag-preview">
          {data.interests?.slice(0, 2).map((interest) => (
            <span key={interest} className="tag-mini">
              {interest}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
};

const CheckInCompactCard = ({ data, onAction }) => {
  return (
    <div className="compact-card checkin-card">
      {/* Main Content */}
      <div className="card-main">
        <img src={data.user.photo} alt={data.user.name} className="user-avatar" />
        <div className="user-quick-info">
          <h4>{data.user.name}, {data.user.age}</h4>
          <p className="location-mini">{data.location.name}</p>
          <span className="status-mini">{data.status}</span>
        </div>
      </div>

      {/* Action */}
      <button className="card-action-arrow" onClick={() => onAction('view', data.id)}>
        ?
      </button>
    </div>
  );
};

const ActivityCompactCard = ({ data, onAction }) => {
  return (
    <div className="compact-card activity-card">
      {/* Header */}
      <div className="card-header">
        <div className="activity-icon">{data.categoryIcon}</div>
        <div className="activity-quick-info">
          <h4>{data.title}</h4>
          <p className="time-mini">{data.displayTime}</p>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="activity-quick-stats">
        <span>?? {data.participantCount}/{data.maxParticipants}</span>
        <span>? {data.timeRemaining}</span>
      </div>

      {/* Action */}
      <button className="card-action-arrow" onClick={() => onAction('join', data.id)}>
        ?
      </button>
    </div>
  );
};

export default CompactCard;
