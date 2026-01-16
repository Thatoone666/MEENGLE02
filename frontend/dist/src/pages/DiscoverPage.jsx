/**
 * Discover Page with Advanced Filters
 * Main page showing matches with filter controls
 */

import React, { useState, useEffect } from 'react';
import AdvancedFiltersModal from '../components/AdvancedFiltersModal';
import ProtectedButton from '../components/ProtectedButton';
import advancedFiltersService from '../services/advancedFiltersService';
import './DiscoverPage.css';

const DiscoverPage = () => {
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState(
    advancedFiltersService.getDefaultFilters()
  );
  const [matches, setMatches] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filtersActive, setFiltersActive] = useState(false);

  useEffect(() => {
    loadMatches();
  }, [filters]);

  const loadMatches = async () => {
    try {
      setLoading(true);

      // Fetch matches from API
      const response = await fetch('/api/v1/matches', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('authToken')}`,
        },
      });

      if (!response.ok) throw new Error('Failed to fetch matches');

      let data = await response.json();

      // Apply filters
      if (advancedFiltersService.areFiltersActive(filters)) {
        data = await advancedFiltersService.applyFilters(data, filters);
        setFiltersActive(true);
      } else {
        setFiltersActive(false);
      }

      setMatches(data);
    } catch (error) {
      console.error('Error loading matches:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFiltersApplied = (newFilters) => {
    setFilters(newFilters);
  };

  const handleResetFilters = () => {
    setFilters(advancedFiltersService.resetFilters());
  };

  return (
    <div className="discover-page">
      {/* Header */}
      <header className="discover-header">
        <h1>?? Discover</h1>
        <div className="header-controls">
          <ProtectedButton
            feature="advancedFilters"
            onClick={() => setShowFilters(true)}
            variant="secondary"
          >
            ?? Advanced Filters
          </ProtectedButton>
          {filtersActive && (
            <button className="reset-btn" onClick={handleResetFilters}>
              ? Reset Filters
            </button>
          )}
        </div>
      </header>

      {/* Filter Active Badge */}
      {filtersActive && (
        <div className="filters-active-badge">
          <span>? Filters Active</span>
          <span className="match-count">{matches.length} matches</span>
        </div>
      )}

      {/* Matches Grid */}
      <div className="matches-container">
        {loading ? (
          <div className="loading">Loading profiles...</div>
        ) : matches.length === 0 ? (
          <div className="no-matches">
            <h2>No matches found</h2>
            <p>Try adjusting your filters to see more people</p>
            <ProtectedButton
              feature="advancedFilters"
              onClick={() => setShowFilters(true)}
              variant="primary"
            >
              Adjust Filters
            </ProtectedButton>
          </div>
        ) : (
          <div className="matches-grid">
            {matches.map((match) => (
              <div key={match.id} className="match-card">
                {/* Main Image */}
                <div className="match-image">
                  <img
                    src={match.photos[0] || '/placeholder.jpg'}
                    alt={match.name}
                  />

                  {/* Info Overlay */}
                  <div className="match-info">
                    <h3>{match.name}, {match.age}</h3>
                    <p className="match-location">?? {match.location}</p>
                  </div>

                  {/* Action Buttons */}
                  <div className="match-actions">
                    <ProtectedButton
                      feature="matches"
                      onClick={() => handlePass(match.id)}
                      className="pass-btn"
                      variant="secondary"
                    >
                      ?
                    </ProtectedButton>
                    <ProtectedButton
                      feature="matches"
                      onClick={() => handleLike(match.id)}
                      className="like-btn"
                      variant="primary"
                    >
                      ??
                    </ProtectedButton>
                  </div>
                </div>

                {/* Profile Info */}
                <div className="match-details">
                  <div className="detail-row">
                    <span className="label">Bio</span>
                    <span className="value">{match.bio}</span>
                  </div>
                  <div className="detail-row">
                    <span className="label">Interests</span>
                    <div className="interests">
                      {match.interests.slice(0, 3).map((interest) => (
                        <span key={interest} className="interest-tag">
                          {interest}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Advanced Filters Modal */}
      <AdvancedFiltersModal
        isOpen={showFilters}
        onClose={() => setShowFilters(false)}
        onFiltersApplied={handleFiltersApplied}
      />
    </div>
  );
};

const handleLike = async (matchId) => {
  try {
    const response = await fetch(`/api/v1/matches/${matchId}/like`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${localStorage.getItem('authToken')}`,
      },
    });

    if (response.ok) {
      // Handle successful like
      console.log('Liked profile');
    }
  } catch (error) {
    console.error('Error liking profile:', error);
  }
};

const handlePass = async (matchId) => {
  try {
    const response = await fetch(`/api/v1/matches/${matchId}/pass`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${localStorage.getItem('authToken')}`,
      },
    });

    if (response.ok) {
      // Handle successful pass
      console.log('Passed on profile');
    }
  } catch (error) {
    console.error('Error passing on profile:', error);
  }
};

export default DiscoverPage;
