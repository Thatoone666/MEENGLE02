/**
 * Activity Discovery Feed Page
 * Displays activities users can join based on interests and location
 */

import React, { useState, useEffect } from 'react';
import ActivityCard from '../components/ActivityCard';
import activityPlanningService from '../services/activityPlanningService';
import ProtectedButton from '../components/ProtectedButton';
import './ActivityDiscoveryPage.css';

const ActivityDiscoveryPage = () => {
  const [activities, setActivities] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentLocation, setCurrentLocation] = useState(null);
  const [filterOpen, setFilterOpen] = useState(false);

  const [filters, setFilters] = useState({
    categories: [],
    skillLevels: [],
    maxDistance: 15,
    maxCost: null,
    ageRange: null,
    onlyFree: false,
    startDate: null,
    endDate: null,
  });

  const activityCategories = activityPlanningService.getActivityCategories();

  useEffect(() => {
    loadActivities();
    startGeolocation();
  }, [filters]);

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

  const loadActivities = async () => {
    try {
      setLoading(true);

      if (currentLocation) {
        const nearby = await activityPlanningService.getNearbyActivities(
          currentLocation.latitude,
          currentLocation.longitude,
          filters.maxDistance,
          {
            categories: filters.categories.join(','),
            skillLevels: filters.skillLevels.join(','),
            maxCost: filters.maxCost,
          }
        );

        const formatted = nearby.map((activity) =>
          activityPlanningService.formatActivity(activity)
        );

        setActivities(formatted);
      }
    } catch (error) {
      console.error('Error loading activities:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = (filterName, value) => {
    setFilters((prev) => {
      if (Array.isArray(prev[filterName])) {
        const current = prev[filterName];
        if (current.includes(value)) {
          return {
            ...prev,
            [filterName]: current.filter((item) => item !== value),
          };
        } else {
          return {
            ...prev,
            [filterName]: [...current, value],
          };
        }
      } else {
        return {
          ...prev,
          [filterName]: value,
        };
      }
    });
  };

  const handleJoin = (activityId, joined) => {
    console.log(`Activity ${activityId} ${joined ? 'joined' : 'left'}`);
  };

  const handleViewDetails = (activityId) => {
    window.location.href = `/activity/${activityId}`;
  };

  const handleViewParticipants = (activityId) => {
    window.location.href = `/activity/${activityId}/participants`;
  };

  const resetFilters = () => {
    setFilters({
      categories: [],
      skillLevels: [],
      maxDistance: 15,
      maxCost: null,
      ageRange: null,
      onlyFree: false,
      startDate: null,
      endDate: null,
    });
  };

  return (
    <div className="activity-discovery-page">
      {/* Header */}
      <header className="activity-header-section">
        <h1>?? Discover Activities</h1>
        <p>Find fun things to do with people near you</p>
      </header>

      {/* Filter Controls */}
      <div className="activity-filters">
        <button
          className="filter-toggle"
          onClick={() => setFilterOpen(!filterOpen)}
        >
          ?? Filters {Object.values(filters).some((v) => (Array.isArray(v) ? v.length > 0 : v)) && <span className="active-badge">?</span>}
        </button>

        {filterOpen && (
          <div className="filter-panel">
            {/* Category Filter */}
            <div className="filter-group">
              <h4>Categories</h4>
              <div className="filter-grid">
                {activityCategories.map((category) => (
                  <label key={category} className="filter-checkbox">
                    <input
                      type="checkbox"
                      checked={filters.categories.includes(category)}
                      onChange={() =>
                        handleFilterChange('categories', category)
                      }
                    />
                    <span>{category}</span>
                  </label>
                ))}
              </div>
            </div>

            {/* Skill Level */}
            <div className="filter-group">
              <h4>Skill Level</h4>
              <div className="filter-options">
                {['Beginner', 'Intermediate', 'Advanced', 'Any'].map(
                  (level) => (
                    <label key={level} className="filter-checkbox">
                      <input
                        type="checkbox"
                        checked={filters.skillLevels.includes(level)}
                        onChange={() =>
                          handleFilterChange('skillLevels', level)
                        }
                      />
                      <span>{level}</span>
                    </label>
                  )
                )}
              </div>
            </div>

            {/* Distance */}
            <div className="filter-group">
              <h4>Distance</h4>
              <div className="distance-slider">
                <input
                  type="range"
                  min="1"
                  max="50"
                  value={filters.maxDistance}
                  onChange={(e) =>
                    handleFilterChange('maxDistance', parseInt(e.target.value))
                  }
                  className="slider"
                />
                <span className="distance-value">
                  {filters.maxDistance} km
                </span>
              </div>
            </div>

            {/* Cost Filter */}
            <div className="filter-group">
              <label className="filter-checkbox">
                <input
                  type="checkbox"
                  checked={filters.onlyFree}
                  onChange={() =>
                    handleFilterChange('onlyFree', !filters.onlyFree)
                  }
                />
                <span>Free Activities Only</span>
              </label>
            </div>

            {/* Reset Button */}
            <button className="reset-filters-btn" onClick={resetFilters}>
              Reset Filters
            </button>
          </div>
        )}
      </div>

      {/* Location Status */}
      {currentLocation && (
        <div className="location-status">
          ?? Showing activities near you
        </div>
      )}

      {/* Activities Feed */}
      <div className="activities-feed">
        {loading ? (
          <div className="loading">Loading activities...</div>
        ) : activities.length === 0 ? (
          <div className="empty-state">
            <h2>No activities found</h2>
            <p>Try adjusting your filters or create your own activity!</p>
            <ProtectedButton
              feature="messages"
              onClick={() => window.location.href = '/create-activity'}
              variant="primary"
            >
              Create Activity
            </ProtectedButton>
          </div>
        ) : (
          <>
            <div className="activities-count">
              {activities.length} {activities.length === 1 ? 'activity' : 'activities'} nearby
            </div>
            {activities.map((activity) => (
              <ActivityCard
                key={activity.id}
                activity={activity}
                onJoin={handleJoin}
                onViewDetails={handleViewDetails}
                onViewParticipants={handleViewParticipants}
              />
            ))}
          </>
        )}
      </div>

      {/* Floating Create Button */}
      <ProtectedButton
        feature="messages"
        onClick={() => window.location.href = '/create-activity'}
        className="floating-create-btn"
        variant="primary"
      >
        ? Create
      </ProtectedButton>
    </div>
  );
};

export default ActivityDiscoveryPage;
