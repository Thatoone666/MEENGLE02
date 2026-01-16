/**
 * PayFlex BNPL (Buy Now Pay Later) Component
 * Allows users to split payments into 3, 6, or 12 month installments
 */

import React, { useState } from 'react';
import saPaymentService from '../services/saPaymentService';
import './PayFlexBNPL.css';

const PayFlexBNPL = ({ amount, currency = 'ZAR', onPaymentStart }) => {
  const [selectedMonths, setSelectedMonths] = useState(3);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const monthlyPayment = saPaymentService.calculateMonthlyPayment(amount, selectedMonths);
  const formattedAmount = saPaymentService.formatCurrency(amount, currency);
  const formattedMonthly = saPaymentService.formatCurrency(monthlyPayment, currency);

  const installmentOptions = [
    {
      months: 3,
      label: '3 Months',
      description: 'R' + saPaymentService.calculateMonthlyPayment(amount, 3).toFixed(2) + '/month',
      interest: 0,
    },
    {
      months: 6,
      label: '6 Months',
      description: 'R' + saPaymentService.calculateMonthlyPayment(amount, 6).toFixed(2) + '/month',
      interest: 0,
    },
    {
      months: 12,
      label: '12 Months',
      description: 'R' + saPaymentService.calculateMonthlyPayment(amount, 12).toFixed(2) + '/month',
      interest: 0,
    },
  ];

  const handlePayment = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await saPaymentService.processPayFlexPayment(
        amount,
        currency,
        selectedMonths,
        {
          description: `Subscription payment - ${selectedMonths} month plan`,
        }
      );

      if (response.checkoutUrl) {
        onPaymentStart({
          method: 'payflex',
          months: selectedMonths,
          monthlyPayment,
        });
        saPaymentService.handlePaymentRedirect(response.checkoutUrl);
      }
    } catch (err) {
      setError(err.message || 'Payment processing failed');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="payflex-bnpl-container">
      <div className="bnpl-header">
        <h3>?? PayFlex - Buy Now, Pay Later</h3>
        <p className="bnpl-subtitle">Split your payment across 3, 6, or 12 months with zero interest</p>
      </div>

      {/* Total Amount */}
      <div className="total-amount-display">
        <p className="amount-label">Total Amount</p>
        <p className="amount-value">{formattedAmount}</p>
      </div>

      {/* Installment Options */}
      <div className="installment-options">
        {installmentOptions.map((option) => (
          <div
            key={option.months}
            className={`installment-card ${selectedMonths === option.months ? 'selected' : ''}`}
            onClick={() => setSelectedMonths(option.months)}
          >
            <div className="option-header">
              <h4 className="option-label">{option.label}</h4>
              {option.interest === 0 && <span className="interest-free">? Interest Free</span>}
            </div>

            <p className="monthly-payment">{option.description}</p>

            <div className="option-details">
              <small>
                {option.months} equal monthly payments • No hidden fees
              </small>
            </div>

            {/* Selection indicator */}
            <div className="option-selector">
              <input
                type="radio"
                name="installment-months"
                value={option.months}
                checked={selectedMonths === option.months}
                onChange={() => setSelectedMonths(option.months)}
              />
            </div>
          </div>
        ))}
      </div>

      {/* Payment Summary */}
      <div className="payment-summary">
        <div className="summary-row">
          <span>Total Amount:</span>
          <span className="summary-value">{formattedAmount}</span>
        </div>
        <div className="summary-row">
          <span>Monthly Payment:</span>
          <span className="summary-value">{formattedMonthly}</span>
        </div>
        <div className="summary-row">
          <span>Number of Payments:</span>
          <span className="summary-value">{selectedMonths}</span>
        </div>
        <div className="summary-row">
          <span>Interest:</span>
          <span className="summary-value interest">FREE (0%)</span>
        </div>
      </div>

      {/* Error Message */}
      {error && <div className="error-message">{error}</div>}

      {/* Payment Button */}
      <button
        className="payflex-pay-button"
        onClick={handlePayment}
        disabled={loading}
      >
        {loading ? 'Processing...' : `Pay with PayFlex - ${selectedMonths} Months`}
      </button>

      {/* Benefits */}
      <div className="bnpl-benefits">
        <h5>Why choose PayFlex?</h5>
        <ul>
          <li>? Zero interest - No hidden charges</li>
          <li>? Flexible payment schedule</li>
          <li>? Easy approval process</li>
          <li>? Secure payment processing</li>
          <li>? South African BNPL provider</li>
        </ul>
      </div>

      {/* Info text */}
      <p className="bnpl-info">
        PayFlex is South Africa's leading Buy Now, Pay Later platform. Your card details are
        secure and processed through PayFlex's encrypted system.
      </p>
    </div>
  );
};

export default PayFlexBNPL;
