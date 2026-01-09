/**
 * Check-In Feed Page
 * Displays nearby check-ins with filtering and interactions
 */

import React, { useState, useEffect } from 'react';
import CheckInCard from '../components/CheckInCard';
import checkInService from '../services/checkInService';
import ProtectedButton from '../components/ProtectedButton';
import './CheckInFeedPage.css';

const CheckInFeedPage = () => {
  const [checkIns, setCheckIns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filterOpen, setFilterOpen] = useState(false);
  const [currentLocation, setCurrentLocation] = useState(null);

  // Filters
  const [filters, setFilters] = useState({
    types: [],
    statuses: [],
    interests: [],
    maxDistance: 10,
    verifiedOnly: false,
    photosOnly: false,
  });

  const filterOptions = checkInService.getFilterOptions();

  useEffect(() => {
    loadCheckIns();
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

  const loadCheckIns = async () => {
    try {
      setLoading(true);

      if (currentLocation) {
        // Get nearby check-ins
        const nearby = await checkInService.getNearbyCheckIns(
          currentLocation.latitude,
          currentLocation.longitude,
          filters.maxDistance,
          {
            types: filters.types.join(','),
            statuses: filters.statuses.join(','),
            interests: filters.interests.join(','),
          }
        );

        // Filter based on user preferences
        const filtered = await checkInService.filterCheckIns(nearby, filters);

        // Format for display
        const formatted = filtered.map((checkIn) =>
          checkInService.formatCheckIn(checkIn)
        );

        setCheckIns(formatted);
      }
    } catch (error) {
      console.error('Error loading check-ins:', error);
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

  const handleLike = (checkInId, isLiked) => {
    console.log(`Check-in ${checkInId} ${isLiked ? 'liked' : 'unliked'}`);
  };

  const handleMessage = (checkInId, message) => {
    console.log(`Message sent to check-in ${checkInId}:`, message);
  };

  const handleViewProfile = (userId) => {
    window.location.href = `/profile/${userId}`;
  };

  const resetFilters = () => {
    setFilters({
      types: [],
      statuses: [],
      interests: [],
      maxDistance: 10,
      verifiedOnly: false,
      photosOnly: false,
    });
  };

  return (
    <div className="check-in-feed-page">
      {/* Header */}
      <header className="check-in-header-section">
        <h1>?? Check-In Feed</h1>
        <p>Connect with people around you</p>
      </header>

      {/* Filter Controls */}
      <div className="filter-controls">
        <button
          className="filter-toggle"
          onClick={() => setFilterOpen(!filterOpen)}
        >
          ?? Filters {Object.values(filters).some((v) => (Array.isArray(v) ? v.length > 0 : v !== 10 && v !== false)) && <span className="active-badge">?</span>}
        </button>

        {filterOpen && (
          <div className="filter-panel">
            {/* Check-In Type Filter */}
            <div className="filter-group">
              <h4>Type</h4>
              <div className="filter-options">
                {filterOptions.types.map((type) => (
                  <label key={type} className="filter-checkbox">
                    <input
                      type="checkbox"
                      checked={filters.types.includes(type)}
                      onChange={() => handleFilterChange('types', type)}
                    />
                    <span>{type}</span>
                  </label>
                ))}
              </div>
            </div>

            {/* Status Filter */}
            <div className="filter-group">
              <h4>Status</h4>
              <div className="filter-options">
                {filterOptions.statuses.map((status) => (
                  <label key={status} className="filter-checkbox">
                    <input
                      type="checkbox"
                      checked={filters.statuses.includes(status)}
                      onChange={() => handleFilterChange('statuses', status)}
                    />
                    <span>{status}</span>
                  </label>
                ))}
              </div>
            </div>

            {/* Distance Filter */}
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

            {/* Verification Filter */}
            <div className="filter-group">
              <label className="filter-checkbox">
                <input
                  type="checkbox"
                  checked={filters.verifiedOnly}
                  onChange={() =>
                    handleFilterChange('verifiedOnly', !filters.verifiedOnly)
                  }
                />
                <span>Verified Only</span>
              </label>
            </div>

            {/* Photos Filter */}
            <div className="filter-group">
              <label className="filter-checkbox">
                <input
                  type="checkbox"
                  checked={filters.photosOnly}
                  onChange={() =>
                    handleFilterChange('photosOnly', !filters.photosOnly)
                  }
                />
                <span>Photos Only</span>
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
          ?? Showing check-ins near you
          <span className="coordinates">
            ({currentLocation.latitude.toFixed(4)}, {currentLocation.longitude.toFixed(4)})
          </span>
        </div>
      )}

      {/* Check-Ins Feed */}
      <div className="check-ins-feed">
        {loading ? (
          <div className="loading">Loading check-ins...</div>
        ) : checkIns.length === 0 ? (
          <div className="empty-state">
            <h2>No check-ins nearby</h2>
            <p>Be the first to check in at your location!</p>
            <ProtectedButton
              feature="messages"
              onClick={() => window.location.href = '/create-check-in'}
              variant="primary"
            >
              Create Check-In
            </ProtectedButton>
          </div>
        ) : (
          <>
            <div className="check-ins-count">
              {checkIns.length} {checkIns.length === 1 ? 'person' : 'people'} nearby
            </div>
            {checkIns.map((checkIn) => (
              <CheckInCard
                key={checkIn.id}
                checkIn={checkIn}
                onLike={handleLike}
                onMessage={handleMessage}
                onViewProfile={handleViewProfile}
              />
            ))}
          </>
        )}
      </div>

      {/* Create Check-In Button (Floating) */}
      <ProtectedButton
        feature="messages"
        onClick={() => window.location.href = '/create-check-in'}
        className="floating-create-btn"
        variant="primary"
      >
        ? Check In
      </ProtectedButton>
    </div>
  );
};

export default CheckInFeedPage;
