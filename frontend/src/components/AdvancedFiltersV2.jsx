/**
 * Advanced Filter Component - REDESIGNED
 * Visual chip-based filtering with progressive disclosure
 * PHASE 4: Visual Improvements
 */

import React, { useState } from 'react';
import ProtectedButton from './ProtectedButton';
import './AdvancedFiltersV2.css';

const AdvancedFiltersV2 = ({ onFiltersApplied, onClose }) => {
  const [filters, setFilters] = useState({
    ageRange: { min: 18, max: 65 },
    distance: 50,
    categories: [],
    skillLevels: [],
    interests: [],
    maxCost: null,
    verification: false,
    photosOnly: false,
  });

  const [activeTab, setActiveTab] = useState('quick');
  const [saving, setSaving] = useState(false);

  const quickFilters = [
    { label: 'Nearby', icon: '??', type: 'distance', value: 5 },
    { label: 'Verified', icon: '?', type: 'verification', value: true },
    { label: 'With Photos', icon: '??', type: 'photosOnly', value: true },
    { label: 'Free', icon: '??', type: 'maxCost', value: 0 },
    { label: 'This Week', icon: '??', type: 'timeRange', value: 'week' },
  ];

  const categoryChips = [
    '? Sports',
    '?? Arts',
    '??? Food',
    '??? Adventure',
    '?? Gaming',
    '?? Music',
    '?? Learning',
    '?? Wellness',
    '?? Travel',
    '?? Social',
  ];

  const skillLevelChips = ['Beginner', 'Intermediate', 'Advanced', 'Any'];

  const handleQuickFilter = (filter) => {
    setFilters((prev) => ({
      ...prev,
      [filter.type]: filter.value,
    }));
  };

  const handleCategoryToggle = (category) => {
    setFilters((prev) => {
      const current = prev.categories;
      if (current.includes(category)) {
        return {
          ...prev,
          categories: current.filter((c) => c !== category),
        };
      } else {
        return {
          ...prev,
          categories: [...current, category],
        };
      }
    });
  };

  const handleSkillToggle = (skill) => {
    setFilters((prev) => {
      const current = prev.skillLevels;
      if (current.includes(skill)) {
        return {
          ...prev,
          skillLevels: current.filter((s) => s !== skill),
        };
      } else {
        return {
          ...prev,
          skillLevels: [...current, skill],
        };
      }
    });
  };

  const handleApplyFilters = async () => {
    try {
      setSaving(true);
      // API call here
      if (onFiltersApplied) {
        onFiltersApplied(filters);
      }
      setTimeout(() => {
        onClose();
      }, 500);
    } finally {
      setSaving(false);
    }
  };

  const activeFilterCount = Object.values(filters).filter(
    (v) => (Array.isArray(v) && v.length > 0) || v === true
  ).length;

  return (
    <div className="filters-v2-container">
      {/* Header */}
      <div className="filters-v2-header">
        <h2>?? Filters</h2>
        {activeFilterCount > 0 && (
          <span className="filter-count">{activeFilterCount} active</span>
        )}
        <button className="filters-close" onClick={onClose}>
          ?
        </button>
      </div>

      {/* Tabs */}
      <div className="filters-v2-tabs">
        <button
          className={`tab ${activeTab === 'quick' ? 'active' : ''}`}
          onClick={() => setActiveTab('quick')}
        >
          ? Quick
        </button>
        <button
          className={`tab ${activeTab === 'advanced' ? 'active' : ''}`}
          onClick={() => setActiveTab('advanced')}
        >
          ?? Advanced
        </button>
      </div>

      {/* Content */}
      <div className="filters-v2-content">
        {activeTab === 'quick' && (
          <div className="quick-filters">
            <p className="section-label">Popular Filters</p>
            <div className="quick-chips">
              {quickFilters.map((filter) => (
                <button
                  key={filter.label}
                  className="quick-chip"
                  onClick={() => handleQuickFilter(filter)}
                >
                  <span className="chip-icon">{filter.icon}</span>
                  <span className="chip-label">{filter.label}</span>
                </button>
              ))}
            </div>
          </div>
        )}

        {activeTab === 'advanced' && (
          <>
            {/* Age Range */}
            <div className="filter-section">
              <h4>Age Range</h4>
              <div className="range-inputs">
                <input
                  type="number"
                  min="18"
                  max="99"
                  value={filters.ageRange.min}
                  onChange={(e) =>
                    setFilters((prev) => ({
                      ...prev,
                      ageRange: {
                        ...prev.ageRange,
                        min: parseInt(e.target.value),
                      },
                    }))
                  }
                />
                <span>—</span>
                <input
                  type="number"
                  min="18"
                  max="99"
                  value={filters.ageRange.max}
                  onChange={(e) =>
                    setFilters((prev) => ({
                      ...prev,
                      ageRange: {
                        ...prev.ageRange,
                        max: parseInt(e.target.value),
                      },
                    }))
                  }
                />
              </div>
            </div>

            {/* Distance */}
            <div className="filter-section">
              <h4>Distance</h4>
              <div className="slider-container">
                <input
                  type="range"
                  min="1"
                  max="50"
                  value={filters.distance}
                  onChange={(e) =>
                    setFilters((prev) => ({
                      ...prev,
                      distance: parseInt(e.target.value),
                    }))
                  }
                  className="slider"
                />
                <span className="slider-value">{filters.distance} km</span>
              </div>
            </div>

            {/* Categories */}
            <div className="filter-section">
              <h4>Categories</h4>
              <div className="chip-group">
                {categoryChips.map((category) => (
                  <button
                    key={category}
                    className={`filter-chip ${
                      filters.categories.includes(category) ? 'active' : ''
                    }`}
                    onClick={() => handleCategoryToggle(category)}
                  >
                    {category}
                  </button>
                ))}
              </div>
            </div>

            {/* Skill Levels */}
            <div className="filter-section">
              <h4>Skill Level</h4>
              <div className="chip-group">
                {skillLevelChips.map((skill) => (
                  <button
                    key={skill}
                    className={`filter-chip ${
                      filters.skillLevels.includes(skill) ? 'active' : ''
                    }`}
                    onClick={() => handleSkillToggle(skill)}
                  >
                    {skill}
                  </button>
                ))}
              </div>
            </div>
          </>
        )}
      </div>

      {/* Action Buttons */}
      <div className="filters-v2-actions">
        <button className="btn-reset" onClick={() => setFilters({
          ageRange: { min: 18, max: 65 },
          distance: 50,
          categories: [],
          skillLevels: [],
          interests: [],
          maxCost: null,
          verification: false,
          photosOnly: false,
        })}>
          Reset
        </button>
        <ProtectedButton
          feature="advancedFilters"
          onClick={handleApplyFilters}
          variant="primary"
          disabled={saving}
        >
          {saving ? 'Applying...' : 'Apply Filters'}
        </ProtectedButton>
      </div>
    </div>
  );
};

export default AdvancedFiltersV2;
