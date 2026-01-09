/**
 * Payment Method Selector Component
 * Displays all 8 SA payment methods with selection UI
 */

import React, { useState, useEffect } from 'react';
import saPaymentService from '../services/saPaymentService';
import './PaymentMethodSelector.css';

const PaymentMethodSelector = ({ onMethodSelected, amount, currency = 'ZAR' }) => {
  const [paymentMethods, setPaymentMethods] = useState([]);
  const [selectedMethod, setSelectedMethod] = useState(null);
  const [recommendedMethod, setRecommendedMethod] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadPaymentMethods();
  }, []);

  const loadPaymentMethods = async () => {
    try {
      setLoading(true);
      const [methods, recommended] = await Promise.all([
        saPaymentService.getPaymentMethods(),
        saPaymentService.getRecommendedPaymentMethod(),
      ]);

      setPaymentMethods(methods || []);
      setRecommendedMethod(recommended?.method);
      setSelectedMethod(recommended?.method);
    } catch (err) {
      setError('Failed to load payment methods');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleMethodSelect = (method) => {
    setSelectedMethod(method);
    onMethodSelected(method);
  };

  const getMethodIcon = (method) => {
    const icons = {
      ozow: '??',
      snapscan: '??',
      payflex: '??',
      yoco: '??',
      capitec: '??',
      payu: '??',
      stripe: '??',
      paypal: '??',
    };
    return icons[method] || '??';
  };

  const getMethodCategory = (method) => {
    const categories = {
      ozow: 'Open Banking',
      snapscan: 'Mobile QR',
      payflex: 'Buy Now Pay Later',
      yoco: 'Card & Mobile',
      capitec: 'Direct Banking',
      payu: 'Card Gateway',
      stripe: 'International Cards',
      paypal: 'Digital Wallet',
    };
    return categories[method] || 'Payment';
  };

  const getMethodFee = (method) => {
    const fees = {
      ozow: '1.2%',
      snapscan: '1.5%',
      payflex: '0%',
      yoco: '2.5%',
      capitec: '1.5%',
      payu: '2.85%',
      stripe: '2.9% + R1.99',
      paypal: '3.49% + R0.49',
    };
    return fees[method] || 'N/A';
  };

  if (loading) {
    return <div className="payment-loader">Loading payment methods...</div>;
  }

  if (error) {
    return <div className="payment-error">{error}</div>;
  }

  return (
    <div className="payment-method-selector">
      <h3 className="payment-title">Choose Payment Method</h3>

      {/* Payment methods grid */}
      <div className="payment-methods-grid">
        {paymentMethods.map((method) => (
          <div
            key={method.id}
            className={`payment-card ${selectedMethod === method.id ? 'selected' : ''} ${
              recommendedMethod === method.id ? 'recommended' : ''
            }`}
            onClick={() => handleMethodSelect(method.id)}
          >
            {/* Recommended badge */}
            {recommendedMethod === method.id && (
              <div className="badge recommended-badge">? Recommended</div>
            )}

            {/* BNPL badge for PayFlex */}
            {method.id === 'payflex' && (
              <div className="badge bnpl-badge">?? BNPL</div>
            )}

            {/* Payment method icon & name */}
            <div className="method-header">
              <span className="method-icon">{getMethodIcon(method.id)}</span>
              <h4 className="method-name">{method.name}</h4>
            </div>

            {/* Category */}
            <p className="method-category">{getMethodCategory(method.id)}</p>

            {/* Description */}
            <p className="method-description">{method.description}</p>

            {/* Fee info */}
            <div className="method-fee">
              <small>Fee: {getMethodFee(method.id)}</small>
            </div>

            {/* Selection indicator */}
            <div className="selection-indicator">
              <input
                type="radio"
                name="payment-method"
                value={method.id}
                checked={selectedMethod === method.id}
                onChange={() => handleMethodSelect(method.id)}
              />
            </div>
          </div>
        ))}
      </div>

      {/* Additional info */}
      {selectedMethod && (
        <div className="payment-method-info">
          <p className="info-text">
            ? {getMethodCategory(selectedMethod)} selected
          </p>
        </div>
      )}
    </div>
  );
};

export default PaymentMethodSelector;
