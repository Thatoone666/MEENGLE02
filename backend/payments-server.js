/**
 * Stripe Webhook Handler & Backend Server Setup
 * Node.js Express server for payment processing
 */

const express = require('express');
const cors = require('cors');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const admin = require('firebase-admin');

const app = express();

// Middleware
app.use(
  cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  })
);

app.use(express.json());

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

// Create Payment Intent
app.post('/api/payments/intent', async (req, res) => {
  try {
    const { amount, currency, metadata } = req.body;

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      metadata,
    });

    res.json({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    console.error('Error creating payment intent:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create Subscription
app.post('/api/payments/subscription', async (req, res) => {
  try {
    const { customerId, priceId, metadata } = req.body;

    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: priceId }],
      metadata,
      expand: ['latest_invoice.payment_intent'],
    });

    res.json(subscription);
  } catch (error) {
    console.error('Error creating subscription:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update Subscription
app.put('/api/payments/subscription/:subscriptionId', async (req, res) => {
  try {
    const { subscriptionId } = req.params;
    const { priceId } = req.body;

    const subscription = await stripe.subscriptions.retrieve(subscriptionId);

    const updatedSubscription = await stripe.subscriptions.update(subscriptionId, {
      items: [
        {
          id: subscription.items.data[0].id,
          price: priceId,
        },
      ],
    });

    res.json(updatedSubscription);
  } catch (error) {
    console.error('Error updating subscription:', error);
    res.status(500).json({ error: error.message });
  }
});

// Cancel Subscription
app.delete('/api/payments/subscription/:subscriptionId', async (req, res) => {
  try {
    const { subscriptionId } = req.params;

    const subscription = await stripe.subscriptions.del(subscriptionId);
    res.json(subscription);
  } catch (error) {
    console.error('Error canceling subscription:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get Subscription
app.get('/api/payments/subscription/:subscriptionId', async (req, res) => {
  try {
    const { subscriptionId } = req.params;

    const subscription = await stripe.subscriptions.retrieve(subscriptionId);
    res.json(subscription);
  } catch (error) {
    console.error('Error getting subscription:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get Billing History
app.get('/api/payments/history/:customerId', async (req, res) => {
  try {
    const { customerId } = req.params;

    const invoices = await stripe.invoices.list({
      customer: customerId,
      limit: 12,
    });

    res.json({ invoices: invoices.data });
  } catch (error) {
    console.error('Error getting billing history:', error);
    res.status(500).json({ error: error.message });
  }
});

// Create Customer
app.post('/api/payments/customer', async (req, res) => {
  try {
    const { email, metadata } = req.body;

    const customer = await stripe.customers.create({
      email,
      metadata,
    });

    res.json(customer);
  } catch (error) {
    console.error('Error creating customer:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get Customer
app.get('/api/payments/customer/:customerId', async (req, res) => {
  try {
    const { customerId } = req.params;

    const customer = await stripe.customers.retrieve(customerId);
    res.json(customer);
  } catch (error) {
    console.error('Error getting customer:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get Payment Methods
app.get('/api/payments/payment-methods/:customerId', async (req, res) => {
  try {
    const { customerId } = req.params;

    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId,
      type: 'card',
    });

    res.json({ paymentMethods: paymentMethods.data });
  } catch (error) {
    console.error('Error getting payment methods:', error);
    res.status(500).json({ error: error.message });
  }
});

// Attach Payment Method
app.post('/api/payments/attach-payment-method', async (req, res) => {
  try {
    const { customerId, paymentMethodId } = req.body;

    const paymentMethod = await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });

    res.json(paymentMethod);
  } catch (error) {
    console.error('Error attaching payment method:', error);
    res.status(500).json({ error: error.message });
  }
});

// Detach Payment Method
app.delete('/api/payments/detach-payment-method/:paymentMethodId', async (req, res) => {
  try {
    const { paymentMethodId } = req.params;

    const paymentMethod = await stripe.paymentMethods.detach(paymentMethodId);
    res.json(paymentMethod);
  } catch (error) {
    console.error('Error detaching payment method:', error);
    res.status(500).json({ error: error.message });
  }
});

// Set Default Payment Method
app.put('/api/payments/default-payment-method', async (req, res) => {
  try {
    const { customerId, paymentMethodId } = req.body;

    const customer = await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });

    res.json(customer);
  } catch (error) {
    console.error('Error setting default payment method:', error);
    res.status(500).json({ error: error.message });
  }
});

// Stripe Webhook
app.post('/api/webhooks/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];

  try {
    const event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );

    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentIntentSucceeded(event.data.object);
        break;

      case 'payment_intent.payment_failed':
        await handlePaymentIntentFailed(event.data.object);
        break;

      case 'customer.subscription.created':
        await handleSubscriptionCreated(event.data.object);
        break;

      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object);
        break;

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;

      case 'invoice.paid':
        await handleInvoicePaid(event.data.object);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(400).send(`Webhook Error: ${error.message}`);
  }
});

// Webhook Handlers
async function handlePaymentIntentSucceeded(paymentIntent) {
  const userId = paymentIntent.metadata.userId;
  const paymentsRef = db.collection('payments');

  await paymentsRef.add({
    userId,
    amount: paymentIntent.amount,
    currency: paymentIntent.currency,
    status: 'succeeded',
    paymentIntentId: paymentIntent.id,
    metadata: paymentIntent.metadata,
    createdAt: new Date(),
  });
}

async function handlePaymentIntentFailed(paymentIntent) {
  const userId = paymentIntent.metadata.userId;
  const paymentsRef = db.collection('payments');

  await paymentsRef.add({
    userId,
    amount: paymentIntent.amount,
    currency: paymentIntent.currency,
    status: 'failed',
    paymentIntentId: paymentIntent.id,
    errorMessage: paymentIntent.last_payment_error?.message,
    metadata: paymentIntent.metadata,
    createdAt: new Date(),
  });
}

async function handleSubscriptionCreated(subscription) {
  const userId = subscription.metadata.userId;
  const subscriptionsRef = db.collection('subscriptions');

  await subscriptionsRef.add({
    userId,
    stripeSubscriptionId: subscription.id,
    stripePriceId: subscription.items.data[0].price.id,
    tier: subscription.metadata.tier,
    status: subscription.status,
    currentPeriodStart: new Date(subscription.current_period_start * 1000),
    currentPeriodEnd: new Date(subscription.current_period_end * 1000),
    createdAt: new Date(),
  });

  // Update user tier
  const usersRef = db.collection('users');
  await usersRef.doc(userId).update({
    tier: subscription.metadata.tier,
    subscriptionStatus: subscription.status === 'active' ? 'active' : 'inactive',
  });
}

async function handleSubscriptionUpdated(subscription) {
  const subscriptionsRef = db.collection('subscriptions');
  const snapshot = await subscriptionsRef
    .where('stripeSubscriptionId', '==', subscription.id)
    .get();

  if (snapshot.size > 0) {
    const doc = snapshot.docs[0];
    await doc.ref.update({
      status: subscription.status,
      tier: subscription.metadata.tier,
      currentPeriodStart: new Date(subscription.current_period_start * 1000),
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
      updatedAt: new Date(),
    });
  }
}

async function handleSubscriptionDeleted(subscription) {
  const subscriptionsRef = db.collection('subscriptions');
  const snapshot = await subscriptionsRef
    .where('stripeSubscriptionId', '==', subscription.id)
    .get();

  if (snapshot.size > 0) {
    const doc = snapshot.docs[0];
    const userId = doc.data().userId;

    await doc.ref.update({
      status: 'canceled',
      updatedAt: new Date(),
    });

    // Downgrade user to free tier
    const usersRef = db.collection('users');
    await usersRef.doc(userId).update({
      tier: 'free',
      subscriptionStatus: 'inactive',
    });
  }
}

async function handleInvoicePaid(invoice) {
  const subscriptionsRef = db.collection('subscriptions');
  const snapshot = await subscriptionsRef
    .where('stripeSubscriptionId', '==', invoice.subscription)
    .get();

  if (snapshot.size > 0) {
    const userId = snapshot.docs[0].data().userId;
    const paymentsRef = db.collection('payments');

    await paymentsRef.add({
      userId,
      amount: invoice.amount_paid,
      currency: invoice.currency,
      status: 'succeeded',
      invoiceId: invoice.id,
      description: 'Subscription payment',
      createdAt: new Date(),
    });
  }
}

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
