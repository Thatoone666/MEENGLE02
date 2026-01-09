/**
 * Empty State Components - REDESIGNED
 * With contextual guidance and illustrations
 * PHASE 4: Better Empty States
 */

import React from 'react';
import ProtectedButton from './ProtectedButton';
import './EmptyStates.css';

const EmptyState = ({ type, context, onAction }) => {
  const emptyStates = {
    // Profiles/Meegling
    profilesNoResults: {
      icon: '??',
      title: 'No profiles nearby',
      subtitle: 'Adjust your filters to find more people',
      suggestions: [
        '?? Increase your search radius',
        '?? Try different filters',
        '? Check back later',
      ],
      actionLabel: 'Adjust Filters',
      actionType: 'filters',
    },

    // Check-Ins
    checkinNoResults: {
      icon: '??',
      title: 'No one checked in nearby yet',
      subtitle: 'Be the first to check in!',
      suggestions: [
        '?? Check in to your current location',
        '?? Let others know you\'re here',
        '?? Start conversations in person',
      ],
      actionLabel: 'Check In Now',
      actionType: 'checkin',
    },

    // Activities
    activitiesNoResults: {
      icon: '??',
      title: 'No activities nearby',
      subtitle: 'Create your own or adjust filters',
      suggestions: [
        '? Try different activity categories',
        '?? Check back tomorrow',
        '?? Create an activity yourself',
      ],
      actionLabel: 'Create Activity',
      actionType: 'create-activity',
    },

    // Messages
    messagesEmpty: {
      icon: '??',
      title: 'No messages yet',
      subtitle: 'Start connecting with people!',
      suggestions: [
        '?? Visit profiles and send messages',
        '?? Like someone to start a match',
        '?? Check in and meet people',
      ],
      actionLabel: 'Start Meegling',
      actionType: 'meegling',
    },

    // Search
    searchNoResults: {
      icon: '??',
      title: 'No results found',
      subtitle: 'Try different search terms',
      suggestions: [
        '?? Use different keywords',
        '??? Expand your location',
        '??? Try broader categories',
      ],
      actionLabel: 'Clear Search',
      actionType: 'clear-search',
    },

    // Favorites
    favoritesEmpty: {
      icon: '?',
      title: 'No favorites yet',
      subtitle: 'Like profiles to save them here',
      suggestions: [
        '?? Start swiping and liking profiles',
        '?? Check-ins from people you like',
        '?? Activities from people near you',
      ],
      actionLabel: 'Start Swiping',
      actionType: 'meegling',
    },

    // Matches
    matchesEmpty: {
      icon: '??',
      title: 'No matches yet',
      subtitle: 'Keep swiping to find your match',
      suggestions: [
        '?? Someone needs to like you back',
        '?? Keep swiping right',
        '?? Join activities to meet people',
      ],
      actionLabel: 'Discover People',
      actionType: 'meegling',
    },

    // Network Error
    networkError: {
      icon: '??',
      title: 'Connection error',
      subtitle: 'Check your internet and try again',
      suggestions: [
        '?? Check your connection',
        '?? Try refreshing',
        '? Try again later',
      ],
      actionLabel: 'Retry',
      actionType: 'retry',
    },

    // Permission Required
    permissionRequired: {
      icon: '??',
      title: 'Permission required',
      subtitle: 'Enable location to find people near you',
      suggestions: [
        '?? Go to settings',
        '?? Enable location access',
        '?? Refresh the app',
      ],
      actionLabel: 'Enable Location',
      actionType: 'location',
    },
  };

  const config = emptyStates[type] || emptyStates.profilesNoResults;

  return (
    <div className="empty-state">
      {/* Icon */}
      <div className="empty-icon">{config.icon}</div>

      {/* Title */}
      <h2 className="empty-title">{config.title}</h2>

      {/* Subtitle */}
      <p className="empty-subtitle">{config.subtitle}</p>

      {/* Suggestions */}
      <div className="empty-suggestions">
        {config.suggestions.map((suggestion, index) => (
          <div key={index} className="suggestion-item">
            {suggestion}
          </div>
        ))}
      </div>

      {/* Action Button */}
      {config.actionType && (
        <ProtectedButton
          feature={
            config.actionType === 'meegling'
              ? 'meegling'
              : config.actionType === 'create-activity'
              ? 'activities'
              : config.actionType === 'checkin'
              ? 'checkin'
              : null
          }
          onClick={() => onAction(config.actionType)}
          variant="primary"
          className="empty-action-btn"
        >
          {config.actionLabel}
        </ProtectedButton>
      )}

      {/* Additional Help */}
      <a href="/help" className="empty-help-link">
        ?? Need help? Check our FAQ
      </a>
    </div>
  );
};

export default EmptyState;
