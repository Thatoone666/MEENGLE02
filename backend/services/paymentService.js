const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const logger = require('../config/logger');

class PaymentService {
  /**
   * Create a payment intent
   */
  async createPaymentIntent(amount, currency = 'usd', metadata = {}) {
    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Convert to cents
        currency,
        metadata,
      });

      logger.info('Payment intent created', { 
        id: paymentIntent.id, 
        amount 
      });

      return paymentIntent;
    } catch (error) {
      logger.error('Failed to create payment intent', { error: error.message });
      throw error;
    }
  }

  /**
   * Confirm a payment intent
   */
  async confirmPaymentIntent(intentId, paymentMethod) {
    try {
      const confirmed = await stripe.paymentIntents.confirm(intentId, {
        payment_method: paymentMethod,
      });

      logger.info('Payment intent confirmed', { id: intentId });
      return confirmed;
    } catch (error) {
      logger.error('Failed to confirm payment intent', { error: error.message });
      throw error;
    }
  }

  /**
   * Create a subscription
   */
  async createSubscription(customerId, priceId, metadata = {}) {
    try {
      const subscription = await stripe.subscriptions.create({
        customer: customerId,
        items: [{ price: priceId }],
        metadata,
      });

      logger.info('Subscription created', { 
        id: subscription.id, 
        customerId 
      });

      return subscription;
    } catch (error) {
      logger.error('Failed to create subscription', { error: error.message });
      throw error;
    }
  }

  /**
   * Cancel a subscription
   */
  async cancelSubscription(subscriptionId) {
    try {
      const cancelled = await stripe.subscriptions.del(subscriptionId);

      logger.info('Subscription cancelled', { id: subscriptionId });
      return cancelled;
    } catch (error) {
      logger.error('Failed to cancel subscription', { error: error.message });
      throw error;
    }
  }

  /**
   * Get payment method
   */
  async getPaymentMethod(paymentMethodId) {
    try {
      const paymentMethod = await stripe.paymentMethods.retrieve(
        paymentMethodId
      );
      return paymentMethod;
    } catch (error) {
      logger.error('Failed to get payment method', { error: error.message });
      throw error;
    }
  }

  /**
   * Create a customer
   */
  async createCustomer(email, metadata = {}) {
    try {
      const customer = await stripe.customers.create({
        email,
        metadata,
      });

      logger.info('Customer created', { id: customer.id, email });
      return customer;
    } catch (error) {
      logger.error('Failed to create customer', { error: error.message });
      throw error;
    }
  }

  /**
   * Retrieve invoice
   */
  async getInvoice(invoiceId) {
    try {
      return await stripe.invoices.retrieve(invoiceId);
    } catch (error) {
      logger.error('Failed to retrieve invoice', { error: error.message });
      throw error;
    }
  }

  /**
   * Handle webhook event
   */
  async handleWebhookEvent(event) {
    try {
      switch (event.type) {
        case 'payment_intent.succeeded':
          logger.info('Payment succeeded', { 
            id: event.data.object.id 
          });
          break;
        case 'payment_intent.payment_failed':
          logger.warn('Payment failed', { 
            id: event.data.object.id 
          });
          break;
        case 'customer.subscription.created':
          logger.info('Subscription created', { 
            id: event.data.object.id 
          });
          break;
        case 'customer.subscription.deleted':
          logger.info('Subscription deleted', { 
            id: event.data.object.id 
          });
          break;
        default:
          logger.debug('Unhandled webhook event', { type: event.type });
      }
      return true;
    } catch (error) {
      logger.error('Failed to handle webhook event', { error: error.message });
      throw error;
    }
  }
}

module.exports = new PaymentService();
