/**
 * Advanced Filters Modal Wrapper
 * Displays advanced filters in a modal overlay
 */

import React, { useState } from 'react';
import AdvancedFilters from '../components/AdvancedFilters';
import './AdvancedFiltersModal.css';

const AdvancedFiltersModal = ({ isOpen, onClose, onFiltersApplied }) => {
  if (!isOpen) return null;

  const handleFiltersApplied = (filters) => {
    if (onFiltersApplied) {
      onFiltersApplied(filters);
    }
    onClose();
  };

  return (
    <div className="filters-modal-overlay">
      <AdvancedFilters
        onFiltersApplied={handleFiltersApplied}
        onClose={onClose}
      />
    </div>
  );
};

export default AdvancedFiltersModal;
