/**
 * Home Dashboard Component
 * Central hub consolidating Meegling, Check-Ins, Activities, and Messages
 * HIGHEST PRIORITY: This is the main entry point after login
 */

import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './HomePage.css';

// Import services
import meelingService from '../services/meelingService';
import checkInService from '../services/checkInService';
import activityPlanningService from '../services/activityPlanningService';
import directMessagingService from '../services/directMessagingService';
import paywallService from '../services/paywallService';

// Import components
import ProtectedButton from '../components/ProtectedButton';
import PaywallModal from '../components/PaywallModal';

const HomePage = () => {
  const navigate = useNavigate();
  const [currentLocation, setCurrentLocation] = useState(null);
  const [userTier, setUserTier] = useState('free');
  const [loading, setLoading] = useState(true);

  // Featured data
  const [featuredMatches, setFeaturedMatches] = useState([]);
  const [featuredCheckIns, setFeaturedCheckIns] = useState([]);
  const [featuredActivities, setFeaturedActivities] = useState([]);
  const [unreadMessages, setUnreadMessages] = useState(0);

  // UI State
  const [showPaywallModal, setShowPaywallModal] = useState(false);
  const [paywallFeature, setPaywallFeature] = useState(null);

  useEffect(() => {
    initializeDashboard();
    startGeolocation();
  }, []);

  const initializeDashboard = async () => {
    try {
      setLoading(true);

      // Get user tier
      const tier = localStorage.getItem('userTier') || 'free';
      setUserTier(tier);

      // Load dashboard data
      await Promise.all([
        loadFeaturedMatches(),
        loadFeaturedCheckIns(),
        loadFeaturedActivities(),
        loadUnreadMessages(),
      ]);
    } catch (error) {
      console.error('Error initializing dashboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const startGeolocation = () => {
    if ('geolocation' in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setCurrentLocation({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
          });
        },
        (error) => console.error('Geolocation error:', error)
      );
    }
  };

  const loadFeaturedMatches = async () => {
    try {
      if (currentLocation) {
        const matches = await meelingService.getProfiles(
          currentLocation.latitude,
          currentLocation.longitude,
          { limit: 3 }
        );
        setFeaturedMatches(matches);
      }
    } catch (error) {
      console.error('Error loading matches:', error);
    }
  };

  const loadFeaturedCheckIns = async () => {
    try {
      if (currentLocation) {
        const checkIns = await checkInService.getNearbyCheckIns(
          currentLocation.latitude,
          currentLocation.longitude,
          5,
          { limit: 2 }
        );
        setFeaturedCheckIns(checkIns);
      }
    } catch (error) {
      console.error('Error loading check-ins:', error);
    }
  };

  const loadFeaturedActivities = async () => {
    try {
      if (currentLocation) {
        const activities = await activityPlanningService.getNearbyActivities(
          currentLocation.latitude,
          currentLocation.longitude,
          10,
          { limit: 2 }
        );
        setFeaturedActivities(activities);
      }
    } catch (error) {
      console.error('Error loading activities:', error);
    }
  };

  const loadUnreadMessages = async () => {
    try {
      const conversations = await directMessagingService.getConversations(1);
      const unread = conversations.filter((c) => c.unreadCount > 0).length;
      setUnreadMessages(unread);
    } catch (error) {
      console.error('Error loading messages:', error);
    }
  };

  const handleFeatureClick = (feature) => {
    // Check if user has access
    if (!paywallService.hasFeatureAccess(userTier, feature)) {
      setPaywallFeature(feature);
      setShowPaywallModal(true);
      return;
    }

    // Navigate to feature
    switch (feature) {
      case 'meegling':
        navigate('/discover');
        break;
      case 'checkin':
        navigate('/checkin-feed');
        break;
      case 'activities':
        navigate('/activities');
        break;
      case 'messages':
        navigate('/messages');
        break;
      default:
        break;
    }
  };

  if (loading) {
    return <div className="home-loading">Loading your Meengle experience...</div>;
  }

  return (
    <div className="home-page">
      {/* Header with Profile Quick Access */}
      <header className="home-header">
        <div className="header-top">
          <h1 className="home-title">Meengle</h1>
          <div className="header-actions">
            <button className="notification-btn" onClick={() => navigate('/notifications')}>
              ?? {unreadMessages > 0 && <span className="badge">{unreadMessages}</span>}
            </button>
            <button className="settings-btn" onClick={() => navigate('/settings')}>
              ??
            </button>
          </div>
        </div>

        {/* Location Status */}
        {currentLocation && (
          <div className="location-status">
            ?? Discovering near you
          </div>
        )}
      </header>

      {/* Main Discovery Grid */}
      <main className="home-main">
        {/* Featured Profiles Section */}
        <section className="home-section">
          <div className="section-header">
            <h2 className="section-title">?? Meegling</h2>
            <button
              className="section-cta"
              onClick={() => handleFeatureClick('meegling')}
            >
              View All ?
            </button>
          </div>

          {featuredMatches.length > 0 ? (
            <div className="profiles-grid">
              {featuredMatches.slice(0, 3).map((match) => (
                <div
                  key={match.id}
                  className="profile-card"
                  onClick={() => navigate(`/profile/${match.id}`)}
                >
                  <div className="profile-image">
                    <img src={match.photos[0]} alt={match.name} />
                    <div className="profile-info-overlay">
                      <h3>{match.name}, {match.age}</h3>
                      <p>{match.bio?.substring(0, 50)}...</p>
                    </div>
                  </div>
                  <div className="profile-actions">
                    <button className="action-btn pass">?</button>
                    <ProtectedButton
                      feature="meegling"
                      onClick={(e) => {
                        e.stopPropagation();
                        navigate(`/profile/${match.id}`);
                      }}
                      variant="primary"
                      className="action-btn like"
                    >
                      ??
                    </ProtectedButton>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="empty-state">
              <p>No profiles nearby yet</p>
              <small>Try expanding your distance filter</small>
            </div>
          )}
        </section>

        {/* Check-Ins Section */}
        <section className="home-section">
          <div className="section-header">
            <h2 className="section-title">?? Check-Ins</h2>
            <button
              className="section-cta"
              onClick={() => handleFeatureClick('checkin')}
            >
              View All ?
            </button>
          </div>

          {featuredCheckIns.length > 0 ? (
            <div className="checkins-list">
              {featuredCheckIns.map((checkIn) => (
                <div
                  key={checkIn.id}
                  className="checkin-item"
                  onClick={() => navigate(`/checkin/${checkIn.id}`)}
                >
                  <img
                    src={checkIn.user.photo}
                    alt={checkIn.user.name}
                    className="checkin-avatar"
                  />
                  <div className="checkin-content">
                    <div className="checkin-header">
                      <h4>{checkIn.user.name}, {checkIn.user.age}</h4>
                      <span className="checkin-time">{checkIn.timeAgo}</span>
                    </div>
                    <p className="checkin-location">
                      {checkIn.location.name}
                    </p>
                    <p className="checkin-status">{checkIn.status}</p>
                  </div>
                  <div className="checkin-arrow">?</div>
                </div>
              ))}
            </div>
          ) : (
            <div className="empty-state">
              <p>No one checked in nearby</p>
              <small>Be the first to check in!</small>
            </div>
          )}
        </section>

        {/* Activities Section */}
        <section className="home-section">
          <div className="section-header">
            <h2 className="section-title">?? Activities</h2>
            <button
              className="section-cta"
              onClick={() => handleFeatureClick('activities')}
            >
              View All ?
            </button>
          </div>

          {featuredActivities.length > 0 ? (
            <div className="activities-list">
              {featuredActivities.map((activity) => (
                <div
                  key={activity.id}
                  className="activity-item"
                  onClick={() => navigate(`/activity/${activity.id}`)}
                >
                  <div className="activity-icon">
                    {activity.category === 'Sports & Fitness' && '?'}
                    {activity.category === 'Arts & Culture' && '??'}
                    {activity.category === 'Food & Dining' && '???'}
                    {activity.category === 'Adventure & Outdoor' && '???'}
                    {activity.category === 'Gaming & Esports' && '??'}
                    {activity.category === 'Music & Entertainment' && '??'}
                  </div>
                  <div className="activity-content">
                    <h4>{activity.title}</h4>
                    <p className="activity-meta">
                      {activity.displayTime} • {activity.participantCount}/{activity.maxParticipants}
                    </p>
                  </div>
                  <div className="activity-arrow">?</div>
                </div>
              ))}
            </div>
          ) : (
            <div className="empty-state">
              <p>No activities nearby</p>
              <small>Create one or filter by category</small>
            </div>
          )}
        </section>
      </main>

      {/* Bottom Action Bar */}
      <div className="home-actions">
        <ProtectedButton
          feature="meegling"
          onClick={() => handleFeatureClick('meegling')}
          variant="primary"
          className="action-card"
        >
          <span className="action-icon">??</span>
          <span className="action-label">Meegle</span>
        </ProtectedButton>

        <ProtectedButton
          feature="checkin"
          onClick={() => handleFeatureClick('checkin')}
          variant="secondary"
          className="action-card"
        >
          <span className="action-icon">??</span>
          <span className="action-label">Check In</span>
        </ProtectedButton>

        <ProtectedButton
          feature="activities"
          onClick={() => handleFeatureClick('activities')}
          variant="secondary"
          className="action-card"
        >
          <span className="action-icon">??</span>
          <span className="action-label">Activities</span>
        </ProtectedButton>

        <ProtectedButton
          feature="messages"
          onClick={() => handleFeatureClick('messages')}
          variant="secondary"
          className="action-card"
        >
          <span className="action-icon">??</span>
          <span className="action-label">Messages</span>
          {unreadMessages > 0 && (
            <span className="action-badge">{unreadMessages}</span>
          )}
        </ProtectedButton>
      </div>

      {/* Paywall Modal */}
      <PaywallModal
        isOpen={showPaywallModal}
        onClose={() => setShowPaywallModal(false)}
        feature={paywallFeature}
      />
    </div>
  );
};

export default HomePage;
