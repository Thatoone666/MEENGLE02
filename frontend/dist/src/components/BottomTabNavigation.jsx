/**
 * Bottom Tab Navigation Component
 * Mobile-standard navigation for young adults
 * SECOND PRIORITY: Essential for mobile UX
 */

import React from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import ProtectedButton from './ProtectedButton';
import './BottomTabNavigation.css';

const BottomTabNavigation = () => {
  const location = useLocation();
  const navigate = useNavigate();

  const tabs = [
    {
      id: 'home',
      label: 'Home',
      icon: '??',
      path: '/home',
      feature: null,
    },
    {
      id: 'discover',
      label: 'Discover',
      icon: '??',
      path: '/discover',
      feature: 'meegling',
    },
    {
      id: 'activities',
      label: 'Activities',
      icon: '??',
      path: '/activities',
      feature: 'activities',
    },
    {
      id: 'messages',
      label: 'Messages',
      icon: '??',
      path: '/messages',
      feature: 'messages',
      badge: true, // Will show unread badge
    },
    {
      id: 'profile',
      label: 'Profile',
      icon: '??',
      path: '/profile',
      feature: null,
    },
  ];

  const isActive = (path) => location.pathname.startsWith(path);
  const unreadMessages = parseInt(localStorage.getItem('unreadMessages') || '0');

  return (
    <nav className="bottom-tab-navigation">
      {tabs.map((tab) => (
        <ProtectedButton
          key={tab.id}
          feature={tab.feature}
          onClick={() => navigate(tab.path)}
          className={`tab-item ${isActive(tab.path) ? 'active' : ''}`}
          variant="ghost"
        >
          <span className="tab-icon">{tab.icon}</span>
          <span className="tab-label">{tab.label}</span>
          {tab.badge && unreadMessages > 0 && (
            <span className="tab-badge">{unreadMessages}</span>
          )}
        </ProtectedButton>
      ))}
    </nav>
  );
};

export default BottomTabNavigation;
