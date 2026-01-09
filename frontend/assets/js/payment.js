// Payment Processing - Stripe integration
class PaymentProcessor {
  constructor() {
    this.apiClient = window.apiClient;
    this.store = window.appStore;
  }

  async createPaymentIntent(amount, currency = 'USD') {
    try {
      this.store.setState({ loading: true });
      
      const result = await this.apiClient.createPaymentIntent(amount, currency);
      
      this.store.setState({ loading: false });
      return result;
    } catch (error) {
      this.store.setState({ loading: false });
      throw error;
    }
  }

  async processPayment(paymentDetails) {
    const { amount, currency, description, metadata } = paymentDetails;

    try {
      this.store.setState({ loading: true });

      // Create payment intent
      const intentResult = await this.createPaymentIntent(amount, currency);

      // In production, would use Stripe Elements/Payment Element
      // For now, return mock success
      const result = {
        success: true,
        paymentId: intentResult.clientSecret || `pay_${Date.now()}`,
        amount,
        currency,
        status: 'succeeded',
        metadata
      };

      this.store.setState({ loading: false });
      return result;
    } catch (error) {
      this.store.setState({ loading: false });
      throw error;
    }
  }

  async verifyPayment(paymentId) {
    try {
      const result = await this.apiClient.verifyPayment(paymentId);
      return result;
    } catch (error) {
      throw error;
    }
  }

  async handleSubscription(tier) {
    const tiers = {
      premium: { amount: 999, name: 'Premium Monthly', interval: 'month' },
      elite: { amount: 2499, name: 'Elite Monthly', interval: 'month' },
      annual: { amount: 9999, name: 'Premium Annual', interval: 'year' }
    };

    const tierData = tiers[tier];
    if (!tierData) throw new Error('Invalid tier');

    return this.processPayment({
      amount: tierData.amount,
      currency: 'USD',
      description: tierData.name,
      metadata: { tier, interval: tierData.interval }
    });
  }

  async handleBoostPurchase(boostType = 'standard') {
    const boosts = {
      standard: { amount: 499, name: 'Standard Boost', duration: 24 },
      premium: { amount: 999, name: 'Premium Boost', duration: 72 },
      mega: { amount: 1999, name: 'Mega Boost', duration: 168 }
    };

    const boostData = boosts[boostType];
    if (!boostData) throw new Error('Invalid boost type');

    return this.processPayment({
      amount: boostData.amount,
      currency: 'USD',
      description: boostData.name,
      metadata: { type: 'boost', boostType, duration: boostData.duration }
    });
  }
}

// Payment UI Component
class PaymentModal {
  static showSubscriptionModal() {
    const tiers = [
      { id: 'premium', name: 'Premium', price: '$9.99/month', features: ['Unlimited likes', 'Advanced filters', 'See who liked you'] },
      { id: 'elite', name: 'Elite', price: '$24.99/month', features: ['Everything in Premium', 'Verified badge', 'Priority support'] },
      { id: 'annual', name: 'Annual Plan', price: '$99.99/year', features: ['Everything in Elite', 'Save 17%', 'Yearly discount'] }
    ];

    let html = '<div class="subscription-tiers">';
    
    tiers.forEach(tier => {
      html += `
        <div class="tier-card">
          <h3>${tier.name}</h3>
          <p class="price">${tier.price}</p>
          <ul class="features">
            ${tier.features.map(f => `<li>? ${f}</li>`).join('')}
          </ul>
          <button class="btn btn-primary" data-tier="${tier.id}" onclick="window.paymentProcessor.handleSubscription('${tier.id}')">
            Subscribe
          </button>
        </div>
      `;
    });

    html += '</div>';

    new window.Modal({
      title: 'Upgrade to Premium',
      content: html,
      className: 'modal-payment'
    }).open();
  }

  static showBoostModal() {
    const boosts = [
      { id: 'standard', name: 'Standard Boost', price: '$4.99', duration: '24 hours' },
      { id: 'premium', name: 'Premium Boost', price: '$9.99', duration: '3 days' },
      { id: 'mega', name: 'Mega Boost', price: '$19.99', duration: '1 week' }
    ];

    let html = '<div class="boost-options">';
    
    boosts.forEach(boost => {
      html += `
        <div class="boost-card">
          <h3>${boost.name}</h3>
          <p class="price">${boost.price}</p>
          <p class="duration">${boost.duration}</p>
          <p class="description">Get maximum visibility</p>
          <button class="btn btn-primary" onclick="window.paymentProcessor.handleBoostPurchase('${boost.id}')">
            Boost Now
          </button>
        </div>
      `;
    });

    html += '</div>';

    new window.Modal({
      title: 'Boost Your Profile',
      content: html,
      className: 'modal-payment'
    }).open();
  }
}

// Paywall/Feature Lock Component
class Paywall {
  static check(feature) {
    const user = window.appStore?.getState()?.user;
    
    const features = {
      'unlimited-likes': user?.tier !== 'free',
      'advanced-filters': user?.tier !== 'free',
      'see-who-liked': user?.tier === 'premium' || user?.tier === 'elite',
      'verified-badge': user?.tier === 'elite',
      'priority-support': user?.tier === 'elite',
      'boost': true, // Everyone can boost
      'export-data': user?.tier !== 'free'
    };

    return features[feature] || false;
  }

  static require(feature, action = null) {
    if (!this.check(feature)) {
      this.showPaywall(feature, action);
      return false;
    }
    return true;
  }

  static showPaywall(feature, action) {
    const messages = {
      'unlimited-likes': 'Upgrade to Premium to get unlimited likes',
      'advanced-filters': 'Upgrade to Premium to use advanced filters',
      'see-who-liked': 'Upgrade to Premium to see who liked you',
      'verified-badge': 'Upgrade to Elite for a verified badge',
      'priority-support': 'Upgrade to Elite for priority support',
      'export-data': 'Upgrade to Premium to export your data'
    };

    new window.Modal({
      title: 'Premium Feature',
      content: `<p>${messages[feature] || 'Upgrade to unlock this feature'}</p>`,
      buttons: [
        { label: 'Cancel', type: 'secondary', action: 'cancel' },
        {
          label: 'Upgrade',
          type: 'primary',
          action: 'upgrade',
          onClick: () => PaymentModal.showSubscriptionModal()
        }
      ]
    }).open();
  }
}

// Wallet/Credits System
class Wallet {
  constructor() {
    this.apiClient = window.apiClient;
    this.store = window.appStore;
  }

  async getBalance() {
    const user = this.store.getState().user;
    return user?.credits || 0;
  }

  async addCredits(amount, description = '') {
    try {
      // Call API to add credits
      const result = await this.apiClient.createPaymentIntent(amount, 'USD');
      
      if (result.success) {
        this.store.setState({
          user: {
            ...this.store.getState().user,
            credits: (this.store.getState().user?.credits || 0) + amount
          }
        });
        
        return result;
      }
    } catch (error) {
      throw error;
    }
  }

  async spendCredits(amount, description = '') {
    const balance = await this.getBalance();
    
    if (balance < amount) {
      throw new Error('Insufficient credits');
    }

    this.store.setState({
      user: {
        ...this.store.getState().user,
        credits: balance - amount
      }
    });
  }

  async getTransactions(limit = 20) {
    // Would call API to get transaction history
    return [];
  }
}

// Receipt/Invoice System
class Receipt {
  static generate(payment) {
    const date = new Date();
    const receiptId = `RCP-${Date.now()}`;

    return {
      id: receiptId,
      date: date.toISOString(),
      amount: payment.amount,
      currency: payment.currency,
      description: payment.description,
      status: 'completed',
      paymentId: payment.paymentId,
      metadata: payment.metadata
    };
  }

  static download(receipt) {
    const content = `
Receipt #${receipt.id}
Date: ${new Date(receipt.date).toLocaleDateString()}
---
${receipt.description}
Amount: ${(receipt.amount / 100).toFixed(2)} ${receipt.currency}
Status: ${receipt.status}
---
Payment ID: ${receipt.paymentId}
    `;

    const blob = new Blob([content], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `receipt-${receipt.id}.txt`;
    a.click();
    URL.revokeObjectURL(url);
  }

  static email(receipt, email) {
    // Call API to email receipt
    return fetch('/api/payments/send-receipt', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ receipt, email })
    });
  }
}

// Initialize payment system
window.PaymentProcessor = PaymentProcessor;
window.PaymentModal = PaymentModal;
window.Paywall = Paywall;
window.Wallet = Wallet;
window.Receipt = Receipt;
window.paymentProcessor = new PaymentProcessor();
window.wallet = new Wallet();

export { PaymentProcessor, PaymentModal, Paywall, Wallet, Receipt };
