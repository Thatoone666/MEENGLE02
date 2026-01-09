/**
 * Feature Gated Section Component
 * Blurs content and shows paywall for restricted features
 */

import React, { useState, useEffect } from 'react';
import PaywallModal from './PaywallModal';
import paywallService from '../services/paywallService';
import './FeatureGated.css';

const FeatureGated = ({
  feature,
  children,
  fallback = null,
  blurRestricted = true,
}) => {
  const [userTier, setUserTier] = useState('free');
  const [isAllowed, setIsAllowed] = useState(false);
  const [showPaywall, setShowPaywall] = useState(false);
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

  const handleUnlock = () => {
    setShowPaywall(false);
    window.location.href = '/payment';
  };

  const requiredTier = paywallService.getTierForFeature(feature);
  const message = paywallService.getPaywallMessage(feature, userTier);

  if (loading) {
    return <div className="feature-gated-loading">Loading...</div>;
  }

  if (!isAllowed && fallback) {
    return fallback;
  }

  return (
    <>
      <div className={`feature-gated ${!isAllowed && blurRestricted ? 'blurred' : ''}`}>
        {children}

        {!isAllowed && blurRestricted && (
          <div className="feature-overlay">
            <div className="overlay-content">
              <div className="overlay-icon">??</div>
              <h3>Premium Feature</h3>
              <p>{paywallService.getPaywallMessage(feature, userTier)}</p>
              <button
                className="overlay-unlock-btn"
                onClick={() => setShowPaywall(true)}
              >
                Unlock Now
              </button>
            </div>
          </div>
        )}
      </div>

      <PaywallModal
        isOpen={showPaywall}
        feature={feature}
        currentTier={userTier}
        requiredTier={requiredTier}
        message={message}
        onClose={() => setShowPaywall(false)}
        onUpgrade={handleUnlock}
      />
    </>
  );
};

export default FeatureGated;
