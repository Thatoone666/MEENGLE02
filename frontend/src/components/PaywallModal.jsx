/**
 * Paywall Modal Component
 * Displays when user hits a feature limit
 */

import React, { useState } from 'react';
import './PaywallModal.css';

const PaywallModal = ({
  isOpen,
  feature,
  currentTier,
  requiredTier,
  message,
  onClose,
  onUpgrade,
}) => {
  const [upgrading, setUpgrading] = useState(false);

  if (!isOpen) return null;

  const tierPricing = {
    spark: { monthly: 9.99, bnpl: 'R2.92/mo' },
    sparkplus: { monthly: 16.99, bnpl: 'R5.83/mo' },
    flame: { monthly: 24.99, bnpl: 'R8.33/mo' },
    wildfire: { monthly: 34.99, bnpl: 'R11.66/mo' },
  };

  const featureEmojis = {
    matches: '??',
    messages: '??',
    dailySwipes: '??',
    videoCalls: '??',
    rewindFeature: '??',
    exclusiveMatches: '?',
    prioritySupport: '??',
    vipEvents: '??',
    advancedFilters: '??',
    adFree: '????',
  };

  const handleUpgrade = async () => {
    setUpgrading(true);
    await onUpgrade();
    setUpgrading(false);
  };

  const emoji = featureEmojis[feature] || '??';
  const pricing = tierPricing[requiredTier];

  return (
    <div className="paywall-overlay">
      <div className="paywall-modal">
        {/* Close Button */}
        <button className="paywall-close" onClick={onClose}>
          ?
        </button>

        {/* Icon */}
        <div className="paywall-icon">{emoji}</div>

        {/* Title */}
        <h2 className="paywall-title">Premium Feature</h2>

        {/* Message */}
        <p className="paywall-message">{message}</p>

        {/* Feature Requirements */}
        <div className="paywall-requirement">
          <p className="requirement-label">This feature requires:</p>
          <div className="tier-badge">
            {requiredTier.charAt(0).toUpperCase() + requiredTier.slice(1)} or
            higher
          </div>
        </div>

        {/* Pricing Info */}
        {pricing && (
          <div className="pricing-info">
            <div className="pricing-option">
              <p className="pricing-label">Monthly</p>
              <p className="pricing-value">R{pricing.monthly}</p>
            </div>
            <div className="pricing-divider">or</div>
            <div className="pricing-option">
              <p className="pricing-label">PayFlex BNPL</p>
              <p className="pricing-value">{pricing.bnpl}</p>
              <p className="pricing-small">12 months interest-free</p>
            </div>
          </div>
        )}

        {/* Benefits List */}
        <div className="paywall-benefits">
          <h4>What you'll get:</h4>
          <ul>
            <li>? Unlimited matches</li>
            <li>? Unlimited messages</li>
            <li>? Advanced filters</li>
            <li>? Priority support</li>
            {requiredTier === 'flame' ||
            requiredTier === 'wildfire' ? (
              <>
                <li>? Video calls</li>
                <li>? Exclusive matches</li>
              </>
            ) : null}
            {requiredTier === 'wildfire' ? (
              <>
                <li>? VIP events</li>
                <li>? Concierge support</li>
              </>
            ) : null}
          </ul>
        </div>

        {/* Action Buttons */}
        <div className="paywall-actions">
          <button
            className="paywall-upgrade-btn"
            onClick={handleUpgrade}
            disabled={upgrading}
          >
            {upgrading ? 'Upgrading...' : 'Upgrade Now'}
          </button>
          <button className="paywall-cancel-btn" onClick={onClose}>
            Maybe Later
          </button>
        </div>

        {/* Trust Badges */}
        <div className="paywall-trust">
          <span>? Secure payment</span>
          <span>? Cancel anytime</span>
          <span>? 30-day refund guarantee</span>
        </div>
      </div>
    </div>
  );
};

export default PaywallModal;
