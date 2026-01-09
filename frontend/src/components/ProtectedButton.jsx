/**
 * Protected Button Component
 * Button that triggers paywall if feature is not available
 */

import React, { useState, useEffect } from 'react';
import PaywallModal from './PaywallModal';
import paywallService from '../services/paywallService';
import './ProtectedButton.css';

const ProtectedButton = ({
  feature,
  children,
  onClick,
  className = '',
  disabled = false,
  variant = 'primary',
}) => {
  const [userTier, setUserTier] = useState('free');
  const [showPaywall, setShowPaywall] = useState(false);
  const [isAllowed, setIsAllowed] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAccess();
  }, [feature]);

  const checkAccess = async () => {
    try {
      setLoading(true);
      const userId = localStorage.getItem('userId');

      if (!userId) {
        setUserTier('free');
        setIsAllowed(false);
        return;
      }

      const tier = await paywallService.getUserTier(userId);
      setUserTier(tier);
      setIsAllowed(paywallService.canAccessFeature(tier, feature));
    } catch (error) {
      console.error('Error checking access:', error);
      setIsAllowed(false);
    } finally {
      setLoading(false);
    }
  };

  const handleClick = async (e) => {
    if (!isAllowed) {
      e.preventDefault();
      setShowPaywall(true);
      return;
    }

    // Record usage and execute callback
    const userId = localStorage.getItem('userId');
    if (userId) {
      await paywallService.recordUsage(userId, feature);
    }

    if (onClick) {
      onClick(e);
    }
  };

  const handleUpgrade = () => {
    setShowPaywall(false);
    window.location.href = '/payment';
  };

  const handleClosePaywall = () => {
    setShowPaywall(false);
  };

  const requiredTier = paywallService.getTierForFeature(feature);
  const message = paywallService.getPaywallMessage(feature, userTier);

  return (
    <>
      <button
        className={`protected-button ${variant} ${!isAllowed ? 'locked' : ''} ${className}`}
        onClick={handleClick}
        disabled={disabled || loading}
        title={!isAllowed ? 'Upgrade to access this feature' : ''}
      >
        {!isAllowed && <span className="lock-icon">?? </span>}
        {children}
      </button>

      <PaywallModal
        isOpen={showPaywall}
        feature={feature}
        currentTier={userTier}
        requiredTier={requiredTier}
        message={message}
        onClose={handleClosePaywall}
        onUpgrade={handleUpgrade}
      />
    </>
  );
};

export default ProtectedButton;
