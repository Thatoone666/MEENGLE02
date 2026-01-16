/**
 * Payment Page Component
 * Main page for subscription upgrades and payments
 * Integrates all 8 SA payment methods with PayFlex BNPL option
 */

import React, { useState, useEffect } from 'react';
import PaymentMethodSelector from '../components/PaymentMethodSelector';
import PayFlexBNPL from '../components/PayFlexBNPL';
import saPaymentService from '../services/saPaymentService';
import './PaymentPage.css';

const PaymentPage = () => {
  const [selectedTier, setSelectedTier] = useState('sparkplus_monthly');
  const [selectedMethod, setSelectedMethod] = useState(null);
  const [showPayFlexOption, setShowPayFlexOption] = useState(false);
  const [processing, setProcessing] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  // Tier pricing
  const tiers = {
    spark_monthly: {
      name: 'Spark',
      price: 9.99,
      features: ['? Spark badge', 'Extended matches', 'More messages'],
    },
    sparkplus_monthly: {
      name: 'Spark+',
      price: 16.99,
      features: ['? Spark+ badge', 'Unlimited matches', 'Unlimited messages', 'Advanced filters'],
      popular: true,
    },
    flame_monthly: {
      name: 'Flame',
      price: 24.99,
      features: ['?? Flame badge', 'All Spark+ features', 'Video calls', 'Premium filters'],
    },
    wildfire_monthly: {
      name: 'Wildfire',
      price: 34.99,
      features: ['??? Wildfire VIP', 'All Flame features', 'Unlimited video calls', 'VIP support'],
      premium: true,
    },
  };

  const currentTier = tiers[selectedTier];
  const currency = 'ZAR';

  const handlePaymentMethod = (method) => {
    setSelectedMethod(method);
    if (method === 'payflex') {
      setShowPayFlexOption(true);
    } else {
      setShowPayFlexOption(false);
    }
  };

  const handlePaymentStart = async (paymentData) => {
    try {
      setProcessing(true);
      setError(null);

      // For non-PayFlex methods, process directly
      if (selectedMethod && selectedMethod !== 'payflex') {
        const response = await saPaymentService.processPayment(
          selectedMethod,
          currentTier.price,
          currency,
          {
            tier: selectedTier,
            tierName: currentTier.name,
          }
        );

        if (response.redirectUrl) {
          saPaymentService.handlePaymentRedirect(response.redirectUrl);
        } else {
          setSuccess(true);
        }
      }
    } catch (err) {
      setError(err.message || 'Payment processing failed');
    } finally {
      setProcessing(false);
    }
  };

  const handleDirectPayment = async (method) => {
    handlePaymentMethod(method);
    await handlePaymentStart({});
  };

  if (success) {
    return (
      <div className="payment-success">
        <div className="success-card">
          <h2>? Payment Successful!</h2>
          <p>Your subscription has been activated.</p>
          <button onClick={() => (window.location.href = '/dashboard')}>
            Go to Dashboard
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="payment-page">
      {/* Header */}
      <header className="payment-header">
        <h1>?? Upgrade Your Account</h1>
        <p>Choose your subscription tier and payment method</p>
      </header>

      <div className="payment-container">
        {/* Left Column - Tier Selection */}
        <div className="tier-selection-column">
          <h2 className="section-title">Select Your Plan</h2>

          <div className="tier-cards">
            {Object.entries(tiers).map(([tierId, tier]) => (
              <div
                key={tierId}
                className={`tier-card ${selectedTier === tierId ? 'selected' : ''} ${
                  tier.popular ? 'popular' : ''
                } ${tier.premium ? 'premium' : ''}`}
                onClick={() => setSelectedTier(tierId)}
              >
                {tier.popular && <div className="tier-badge">Most Popular</div>}
                {tier.premium && <div className="tier-badge premium-badge">Premium</div>}

                <h3 className="tier-name">{tier.name}</h3>

                <div className="tier-price">
                  <span className="currency">R</span>
                  <span className="amount">{tier.price.toFixed(2)}</span>
                  <span className="period">/month</span>
                </div>

                <ul className="tier-features">
                  {tier.features.map((feature, idx) => (
                    <li key={idx}>{feature}</li>
                  ))}
                </ul>

                <button className="select-btn">
                  {selectedTier === tierId ? '? Selected' : 'Select'}
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Right Column - Payment Methods */}
        <div className="payment-column">
          {error && <div className="error-message">{error}</div>}

          {/* Payment Method Selector */}
          <PaymentMethodSelector
            onMethodSelected={handlePaymentMethod}
            amount={currentTier.price}
            currency={currency}
          />

          {/* PayFlex BNPL Option */}
          {showPayFlexOption && (
            <PayFlexBNPL
              amount={currentTier.price}
              currency={currency}
              onPaymentStart={handlePaymentStart}
            />
          )}

          {/* Direct Payment Button (for non-PayFlex) */}
          {selectedMethod && selectedMethod !== 'payflex' && (
            <button
              className="direct-payment-btn"
              onClick={() => handleDirectPayment(selectedMethod)}
              disabled={processing}
            >
              {processing ? 'Processing Payment...' : 'Proceed to Payment'}
            </button>
          )}

          {/* Payment Info */}
          <div className="payment-info">
            <h4>Payment Information</h4>
            <p>
              ? All payments are secure and encrypted
            </p>
            <p>
              ? 30-day money-back guarantee on first purchase
            </p>
            <p>
              ? Cancel anytime, no hidden fees
            </p>
          </div>
        </div>
      </div>

      {/* Features Comparison */}
      <section className="features-section">
        <h2 className="section-title">What's Included</h2>

        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-icon">??</div>
            <h4>Mobile Optimized</h4>
            <p>All features work seamlessly on your phone</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">??</div>
            <h4>Secure Payments</h4>
            <p>Multiple payment options with bank-level security</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">??</div>
            <h4>PayFlex BNPL</h4>
            <p>Split payments into 3, 6, or 12 months (interest-free)</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">????</div>
            <h4>Local & International</h4>
            <p>8 SA payment methods + Stripe & PayPal</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">?</div>
            <h4>Instant Activation</h4>
            <p>Your plan activates immediately after payment</p>
          </div>

          <div className="feature-card">
            <div className="feature-icon">??</div>
            <h4>Transparent Pricing</h4>
            <p>No hidden charges or surprise fees</p>
          </div>
        </div>
      </section>
    </div>
  );
};

export default PaymentPage;
