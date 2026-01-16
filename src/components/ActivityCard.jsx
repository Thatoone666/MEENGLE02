/**
 * Activity Card Component
 * Displays individual activity with join/details options
 */

import React, { useState } from 'react';
import activityPlanningService from '../services/activityPlanningService';
import ProtectedButton from './ProtectedButton';
import './ActivityCard.css';

const ActivityCard = ({
  activity,
  onJoin,
  onViewDetails,
  onViewParticipants,
}) => {
  const [isJoined, setIsJoined] = useState(activity.isUserParticipant);
  const [participantCount, setParticipantCount] = useState(
    activity.participantCount
  );
  const [loading, setLoading] = useState(false);

  const handleJoinLeave = async () => {
    try {
      setLoading(true);

      if (isJoined) {
        await activityPlanningService.leaveActivity(
          activity.id,
          activity.currentUserId
        );
        setParticipantCount(participantCount - 1);
        setIsJoined(false);
      } else {
        await activityPlanningService.joinActivity(
          activity.id,
          activity.currentUserId
        );
        setParticipantCount(participantCount + 1);
        setIsJoined(true);
      }

      if (onJoin) onJoin(activity.id, !isJoined);
    } catch (error) {
      console.error('Error joining/leaving activity:', error);
    } finally {
      setLoading(false);
    }
  };

  const getCategoryIcon = (category) => {
    const icons = {
      'Sports & Fitness': '?',
      'Arts & Culture': '??',
      'Food & Dining': '???',
      'Adventure & Outdoor': '???',
      'Gaming & Esports': '??',
      'Music & Entertainment': '??',
      'Learning & Workshops': '??',
      'Wellness & Yoga': '??',
      'Travel & Exploration': '??',
      'Social & Networking': '??',
      'Movie & Cinema': '??',
      'Photography': '??',
      'Book Club': '??',
      'Volunteering': '??',
      'Beach & Water Sports': '???',
      'Hiking & Nature': '??',
      'Fitness Classes': '??',
      'Cooking Classes': '?????',
      'Language Exchange': '??',
      'Pet Friendly': '??',
    };
    return icons[category] || '??';
  };

  const getDifficultyColor = (level) => {
    const colors = {
      Beginner: '#4caf50',
      Intermediate: '#ff9800',
      Advanced: '#f44336',
      Any: '#2196f3',
    };
    return colors[level] || '#757575';
  };

  const formatted = activityPlanningService.formatActivity(activity);

  return (
    <div className="activity-card">
      {/* Header with category and time */}
      <div className="activity-header">
        <div className="category-info">
          <span className="category-icon">
            {getCategoryIcon(activity.category)}
          </span>
          <div className="category-details">
            <h3 className="activity-title">{activity.title}</h3>
            <p className="activity-category">{activity.category}</p>
          </div>
        </div>
        <div className="activity-time">
          <p className="time-value">{formatted.displayTime}</p>
          <p className="date-value">{formatted.displayDate}</p>
        </div>
      </div>

      {/* Description */}
      <p className="activity-description">{activity.description}</p>

      {/* Location */}
      <div className="activity-location">
        ?? {activity.location.name}, {activity.location.city}
        {activity.distance && (
          <span className="distance">({activity.distance.toFixed(1)} km away)</span>
        )}
      </div>

      {/* Tags/Skills */}
      <div className="activity-tags">
        {activity.tags && activity.tags.length > 0 && (
          <>
            {activity.tags.slice(0, 3).map((tag) => (
              <span key={tag} className="tag">
                {tag}
              </span>
            ))}
            {activity.tags.length > 3 && (
              <span className="tag-more">+{activity.tags.length - 3}</span>
            )}
          </>
        )}
        <span
          className="difficulty-badge"
          style={{ backgroundColor: getDifficultyColor(activity.skillLevel) }}
        >
          {activity.skillLevel}
        </span>
      </div>

      {/* Activity Meta */}
      <div className="activity-meta">
        <div className="meta-item">
          <span className="meta-icon">??</span>
          <span className="meta-text">
            {participantCount}/{activity.maxParticipants}
          </span>
        </div>

        {activity.cost > 0 && (
          <div className="meta-item">
            <span className="meta-icon">??</span>
            <span className="meta-text">R{activity.cost}</span>
          </div>
        )}

        <div className="meta-item">
          <span className="meta-icon">?</span>
          <span className="meta-text">{formatted.timeRemaining}</span>
        </div>

        <div className="meta-item">
          <span className="meta-icon">??</span>
          <span className="meta-text">{activity.ageRange}</span>
        </div>
      </div>

      {/* Organizer Info */}
      <div className="organizer-section">
        <img
          src={activity.organizer.photo}
          alt={activity.organizer.name}
          className="organizer-photo"
        />
        <div className="organizer-info">
          <p className="organizer-name">
            Organized by <strong>{activity.organizer.name}</strong>
          </p>
          <p className="organizer-rating">
            ? {activity.organizerRating.toFixed(1)} (
            {activity.organizerReviews} reviews)
          </p>
        </div>
      </div>

      {/* Required Equipment */}
      {activity.requiredEquipment && activity.requiredEquipment.length > 0 && (
        <div className="equipment-section">
          <p className="equipment-label">Required: {activity.requiredEquipment.join(', ')}</p>
        </div>
      )}

      {/* Action Buttons */}
      <div className="activity-actions">
        <button
          className={`join-btn ${isJoined ? 'joined' : ''}`}
          onClick={handleJoinLeave}
          disabled={
            loading ||
            (!isJoined && formatted.isFull && !isJoined)
          }
        >
          {loading ? '...' : isJoined ? '? Joined' : 'Join Activity'}
        </button>

        <button
          className="details-btn"
          onClick={() => onViewDetails && onViewDetails(activity.id)}
        >
          Details
        </button>

        <ProtectedButton
          feature="messages"
          onClick={() =>
            onViewParticipants && onViewParticipants(activity.id)
          }
          variant="secondary"
        >
          ?? ({participantCount})
        </ProtectedButton>
      </div>

      {/* Status Indicator */}
      {formatted.isFull && (
        <div className="full-badge">Activity Full</div>
      )}

      {activity.isUserOrganizer && (
        <div className="organizer-badge">You're hosting this</div>
      )}
    </div>
  );
};

export default ActivityCard;
