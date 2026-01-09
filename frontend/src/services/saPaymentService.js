/**
 * South African Payment Service (Frontend)
 * Handles all 8 SA payment methods + international options
 */

class SAPaymentService {
  constructor() {
    this.apiEndpoint = process.env.REACT_APP_API_URL || 'http://localhost:3000/api/v1';
    this.paymentMethods = [
      'ozow',
      'snapscan',
      'payflex',
      'yoco',
      'capitec',
      'payu',
      'stripe',
      'paypal',
    ];
  }

  /**
   * Get all available payment methods
   */
  async getPaymentMethods() {
    try {
      const response = await fetch(`${this.apiEndpoint}/payments/methods`, {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to fetch payment methods');
      return await response.json();
    } catch (error) {
      console.error('Error fetching payment methods:', error);
      throw error;
    }
  }

  /**
   * Get recommended payment method for user
   */
  async getRecommendedPaymentMethod() {
    try {
      const userLocation = this.getUserLocation();
      const response = await fetch(
        `${this.apiEndpoint}/payments/recommended?location=${userLocation}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) throw new Error('Failed to fetch recommended method');
      return await response.json();
    } catch (error) {
      console.error('Error fetching recommended method:', error);
      return 'ozow'; // Default fallback
    }
  }

  /**
   * Process payment with selected method
   */
  async processPayment(method, amount, currency, metadata = {}) {
    try {
      const response = await fetch(`${this.apiEndpoint}/payments/process`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          method,
          amount,
          currency,
          metadata,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'Payment processing failed');
      }

      return await response.json();
    } catch (error) {
      console.error('Error processing payment:', error);
      throw error;
    }
  }

  /**
   * Process PayFlex BNPL payment with installments
   */
  async processPayFlexPayment(amount, currency, installments, metadata = {}) {
    try {
      const response = await fetch(`${this.apiEndpoint}/payments/payflex`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          amount,
          currency,
          installments,
          metadata,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || 'PayFlex payment failed');
      }

      return await response.json();
    } catch (error) {
      console.error('Error processing PayFlex payment:', error);
      throw error;
    }
  }

  /**
   * Verify payment status
   */
  async verifyPayment(transactionId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/payments/verify/${transactionId}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) throw new Error('Failed to verify payment');
      return await response.json();
    } catch (error) {
      console.error('Error verifying payment:', error);
      throw error;
    }
  }

  /**
   * Get payment method details
   */
  async getPaymentMethodDetails(method) {
    try {
      const response = await fetch(`${this.apiEndpoint}/payments/methods/${method}`, {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to fetch method details');
      return await response.json();
    } catch (error) {
      console.error('Error fetching method details:', error);
      throw error;
    }
  }

  /**
   * Calculate PayFlex monthly payment
   */
  calculateMonthlyPayment(amount, months) {
    return Math.round((amount / months) * 100) / 100;
  }

  /**
   * Format currency for display
   */
  formatCurrency(amount, currency = 'ZAR') {
    const symbols = {
      ZAR: 'R',
      USD: '$',
      EUR: '€',
    };

    const symbol = symbols[currency] || currency;
    return `${symbol}${amount.toFixed(2)}`;
  }

  /**
   * Handle redirect for payment methods that need it
   */
  handlePaymentRedirect(redirectUrl) {
    if (redirectUrl) {
      window.location.href = redirectUrl;
    }
  }

  /**
   * Get auth token from localStorage
   */
  getAuthToken() {
    return localStorage.getItem('authToken') || '';
  }

  /**
   * Get user location (mock - replace with actual geolocation)
   */
  getUserLocation() {
    return 'ZA'; // Default to South Africa
  }

  /**
   * Handle payment webhook callback
   */
  handlePaymentCallback(callbackData) {
    return {
      transactionId: callbackData.transactionId,
      status: callbackData.status,
      amount: callbackData.amount,
      method: callbackData.method,
    };
  }
}

export default new SAPaymentService();
