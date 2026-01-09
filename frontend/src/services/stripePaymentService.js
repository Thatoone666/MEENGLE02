/**
 * Stripe Payment Service
 * Handles payment intents, subscriptions, and billing
 */

class StripePaymentService {
  constructor() {
    this.publishableKey = process.env.REACT_APP_STRIPE_PUBLISHABLE_KEY;
    this.apiEndpoint = process.env.REACT_APP_API_ENDPOINT || 'http://localhost:3001';
  }

  async createPaymentIntent(amount, currency = 'usd', metadata = {}) {
    try {
      const response = await fetch(`${this.apiEndpoint}/api/payments/intent`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          amount,
          currency,
          metadata,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to create payment intent');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error creating payment intent:', error);
      throw error;
    }
  }

  async createSubscription(customerId, priceId, metadata = {}) {
    try {
      const response = await fetch(`${this.apiEndpoint}/api/payments/subscription`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          customerId,
          priceId,
          metadata,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to create subscription');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error creating subscription:', error);
      throw error;
    }
  }

  async updateSubscription(subscriptionId, newPriceId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/api/payments/subscription/${subscriptionId}`,
        {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            priceId: newPriceId,
          }),
        }
      );

      if (!response.ok) {
        throw new Error('Failed to update subscription');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error updating subscription:', error);
      throw error;
    }
  }

  async cancelSubscription(subscriptionId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/api/payments/subscription/${subscriptionId}`,
        {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      if (!response.ok) {
        throw new Error('Failed to cancel subscription');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error canceling subscription:', error);
      throw error;
    }
  }

  async getBillingHistory(customerId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/api/payments/history/${customerId}`
      );

      if (!response.ok) {
        throw new Error('Failed to get billing history');
      }

      const data = await response.json();
      return data.invoices || [];
    } catch (error) {
      console.error('Error getting billing history:', error);
      throw error;
    }
  }

  async getSubscription(subscriptionId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/api/payments/subscription/${subscriptionId}`
      );

      if (!response.ok) {
        throw new Error('Failed to get subscription');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error getting subscription:', error);
      throw error;
    }
  }

  async getCustomer(customerId) {
    try {
      const response = await fetch(`${this.apiEndpoint}/api/payments/customer/${customerId}`);

      if (!response.ok) {
        throw new Error('Failed to get customer');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error getting customer:', error);
      throw error;
    }
  }

  async createCustomer(email, metadata = {}) {
    try {
      const response = await fetch(`${this.apiEndpoint}/api/payments/customer`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          metadata,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to create customer');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error creating customer:', error);
      throw error;
    }
  }

  async attachPaymentMethod(customerId, paymentMethodId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/api/payments/attach-payment-method`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            customerId,
            paymentMethodId,
          }),
        }
      );

      if (!response.ok) {
        throw new Error('Failed to attach payment method');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error attaching payment method:', error);
      throw error;
    }
  }

  async detachPaymentMethod(paymentMethodId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/api/payments/detach-payment-method/${paymentMethodId}`,
        {
          method: 'DELETE',
        }
      );

      if (!response.ok) {
        throw new Error('Failed to detach payment method');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error detaching payment method:', error);
      throw error;
    }
  }

  async getPaymentMethods(customerId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/api/payments/payment-methods/${customerId}`
      );

      if (!response.ok) {
        throw new Error('Failed to get payment methods');
      }

      const data = await response.json();
      return data.paymentMethods || [];
    } catch (error) {
      console.error('Error getting payment methods:', error);
      throw error;
    }
  }

  async setDefaultPaymentMethod(customerId, paymentMethodId) {
    try {
      const response = await fetch(
        `${this.apiEndpoint}/api/payments/default-payment-method`,
        {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            customerId,
            paymentMethodId,
          }),
        }
      );

      if (!response.ok) {
        throw new Error('Failed to set default payment method');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Error setting default payment method:', error);
      throw error;
    }
  }

  getPublishableKey() {
    return this.publishableKey;
  }
}

export default new StripePaymentService();
