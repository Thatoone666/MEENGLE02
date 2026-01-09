const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const logger = require('../config/logger');

/**
 * South African Payment Methods Service
 * Supports 8 local payment methods + Stripe
 */
class SAPaymentService {
  constructor() {
    this.providers = {
      stripe: 'stripe', // International card payments
      paypal: 'paypal', // PayPal South Africa
      snapscan: 'snapscan', // QR code/mobile payments
      yoco: 'yoco', // Card & mobile payments
      payu: 'payu', // PayU South Africa (formerly Poli)
      payflex: 'payflex', // Buy now pay later (BNPL)
      capitec: 'capitec', // Capitec Bank direct
      ozow: 'ozow', // Open banking/EFT
    };

    this.currencies = {
      ZAR: 'ZAR', // South African Rand (primary)
      USD: 'USD', // US Dollar
      EUR: 'EUR', // Euro
    };
  }

  /**
   * Process Stripe payment (International cards, Visa, Mastercard, Amex)
   */
  async processStripePayment(amount, currency, metadata = {}) {
    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Convert to cents
        currency: currency.toLowerCase(),
        metadata,
        payment_method_types: ['card'],
      });

      logger.info('Stripe payment intent created', {
        id: paymentIntent.id,
        amount,
        currency,
      });

      return {
        success: true,
        provider: 'stripe',
        paymentIntentId: paymentIntent.id,
        clientSecret: paymentIntent.client_secret,
        status: paymentIntent.status,
      };
    } catch (error) {
      logger.error('Stripe payment failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Process SnapScan payment (QR code, local mobile payments)
   * SnapScan: Popular in SA for instant mobile payments
   */
  async processSnapScan(amount, currency = 'ZAR', metadata = {}) {
    try {
      // SnapScan integration via API
      const snapscanResponse = await this.callSnapScanAPI({
        amount: Math.round(amount * 100),
        currency,
        description: metadata.description || 'Meengle Subscription',
        metadata,
      });

      logger.info('SnapScan payment initiated', {
        transactionId: snapscanResponse.id,
        amount,
      });

      return {
        success: true,
        provider: 'snapscan',
        transactionId: snapscanResponse.id,
        qrCode: snapscanResponse.qrCode,
        deepLink: snapscanResponse.deepLink,
        status: 'pending',
      };
    } catch (error) {
      logger.error('SnapScan payment failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Process Yoco payment (Card & mobile)
   * Yoco: Easy payment processing for SA businesses
   */
  async processYoco(amount, currency = 'ZAR', metadata = {}) {
    try {
      const yocoResponse = await this.callYocoAPI({
        amount: Math.round(amount * 100),
        currency,
        metadata,
      });

      logger.info('Yoco payment processed', {
        transactionId: yocoResponse.id,
        amount,
      });

      return {
        success: true,
        provider: 'yoco',
        transactionId: yocoResponse.id,
        status: yocoResponse.status,
      };
    } catch (error) {
      logger.error('Yoco payment failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Process PayU payment (Credit/Debit card)
   * PayU: Major payment gateway in South Africa
   */
  async processPayU(amount, currency = 'ZAR', metadata = {}) {
    try {
      const payuResponse = await this.callPayUAPI({
        amount: Math.round(amount * 100),
        currency,
        description: metadata.description || 'Meengle Subscription',
        customerEmail: metadata.email,
        customerId: metadata.userId,
      });

      logger.info('PayU payment initiated', {
        transactionId: payuResponse.reference,
        amount,
      });

      return {
        success: true,
        provider: 'payu',
        transactionId: payuResponse.reference,
        redirectUrl: payuResponse.redirect_url,
        status: payuResponse.status,
      };
    } catch (error) {
      logger.error('PayU payment failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Process PayFlex payment (Buy Now Pay Later - BNPL)
   * PayFlex: Popular BNPL in SA - Split into 3/6/12 months interest-free
   */
  async processPayFlex(
    amount,
    currency = 'ZAR',
    installments = 3,
    metadata = {}
  ) {
    try {
      // PayFlex supports 3, 6, and 12 month installments
      if (![3, 6, 12].includes(installments)) {
        throw new Error('PayFlex supports 3, 6, or 12 month installments');
      }

      const flexResponse = await this.callPayFlexAPI({
        amount: Math.round(amount * 100),
        currency,
        installments,
        description: metadata.description || 'Meengle Subscription',
        customerId: metadata.userId,
        customerEmail: metadata.email,
      });

      logger.info('PayFlex BNPL initiated', {
        transactionId: flexResponse.id,
        amount,
        installments,
      });

      return {
        success: true,
        provider: 'payflex',
        type: 'BNPL', // Buy Now Pay Later
        transactionId: flexResponse.id,
        installments,
        monthlyPayment: Math.round(amount / installments * 100) / 100,
        checkoutUrl: flexResponse.checkout_url,
        status: 'pending',
      };
    } catch (error) {
      logger.error('PayFlex payment failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Process Capitec Bank payment (Direct banking)
   * Capitec: Direct integration with SA's 4th largest bank
   */
  async processCapitec(amount, currency = 'ZAR', metadata = {}) {
    try {
      const capitecResponse = await this.callCapitecAPI({
        amount: Math.round(amount * 100),
        currency,
        description: metadata.description || 'Meengle Subscription',
        customerId: metadata.userId,
        customerEmail: metadata.email,
      });

      logger.info('Capitec payment initiated', {
        transactionId: capitecResponse.reference,
        amount,
      });

      return {
        success: true,
        provider: 'capitec',
        transactionId: capitecResponse.reference,
        redirectUrl: capitecResponse.redirect_url,
        status: 'pending',
      };
    } catch (error) {
      logger.error('Capitec payment failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Process Ozow payment (Open banking/EFT)
   * Ozow: Popular open banking platform connecting to all SA banks
   */
  async processOzow(amount, currency = 'ZAR', metadata = {}) {
    try {
      const ozowResponse = await this.callOzowAPI({
        amount: Math.round(amount * 100),
        currency,
        bankAccount: metadata.bankAccount,
        customerId: metadata.userId,
        customerEmail: metadata.email,
        customerName: metadata.name,
      });

      logger.info('Ozow payment initiated', {
        transactionId: ozowResponse.id,
        amount,
      });

      return {
        success: true,
        provider: 'ozow',
        transactionId: ozowResponse.id,
        redirectUrl: ozowResponse.redirect_url,
        status: 'pending',
      };
    } catch (error) {
      logger.error('Ozow payment failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Process PayPal payment
   * PayPal: International option, works in South Africa
   */
  async processPayPal(amount, currency = 'ZAR', metadata = {}) {
    try {
      const paypalResponse = await this.callPayPalAPI({
        amount: amount.toString(),
        currency,
        description: metadata.description || 'Meengle Subscription',
        returnUrl: metadata.returnUrl,
        cancelUrl: metadata.cancelUrl,
      });

      logger.info('PayPal payment initiated', {
        transactionId: paypalResponse.id,
        amount,
      });

      return {
        success: true,
        provider: 'paypal',
        transactionId: paypalResponse.id,
        redirectUrl: paypalResponse.approvalUrl,
        status: 'pending',
      };
    } catch (error) {
      logger.error('PayPal payment failed', { error: error.message });
      throw error;
    }
  }

  /**
   * Get payment method details
   */
  async getPaymentMethod(provider) {
    const methods = {
      stripe: {
        name: 'Stripe',
        type: 'card',
        icon: '??',
        currency: ['ZAR', 'USD', 'EUR'],
        description:
          'Visa, Mastercard, American Express',
        logo: 'stripe-logo.png',
        supported: true,
      },
      snapscan: {
        name: 'SnapScan',
        type: 'mobile',
        icon: '??',
        currency: ['ZAR'],
        description: 'Instant mobile payments via QR code',
        logo: 'snapscan-logo.png',
        supported: true,
      },
      yoco: {
        name: 'Yoco',
        type: 'card_mobile',
        icon: '??',
        currency: ['ZAR'],
        description: 'Card & mobile payments',
        logo: 'yoco-logo.png',
        supported: true,
      },
      payu: {
        name: 'PayU',
        type: 'card',
        icon: '??',
        currency: ['ZAR'],
        description: 'Credit & Debit cards',
        logo: 'payu-logo.png',
        supported: true,
      },
      payflex: {
        name: 'PayFlex',
        type: 'bnpl',
        icon: '??',
        currency: ['ZAR'],
        description: 'Buy now, pay later - 3/6/12 months',
        logo: 'payflex-logo.png',
        supported: true,
        installments: [3, 6, 12],
      },
      capitec: {
        name: 'Capitec Bank',
        type: 'banking',
        icon: '??',
        currency: ['ZAR'],
        description: 'Direct bank transfer',
        logo: 'capitec-logo.png',
        supported: true,
      },
      ozow: {
        name: 'Ozow',
        type: 'open_banking',
        icon: '??',
        currency: ['ZAR'],
        description: 'Pay directly from your bank',
        logo: 'ozow-logo.png',
        supported: true,
      },
      paypal: {
        name: 'PayPal',
        type: 'wallet',
        icon: '??',
        currency: ['USD', 'ZAR'],
        description: 'PayPal wallet',
        logo: 'paypal-logo.png',
        supported: true,
      },
    };

    return methods[provider] || null;
  }

  /**
   * Get all supported payment methods
   */
  async getAllPaymentMethods() {
    const methods = [];
    for (const provider of Object.values(this.providers)) {
      const method = await this.getPaymentMethod(provider);
      if (method) {
        methods.push(method);
      }
    }
    return methods;
  }

  /**
   * Get recommended payment method for user
   */
  getRecommendedPaymentMethod(userLocation = 'ZA', userPreference = null) {
    if (userPreference && this.providers[userPreference]) {
      return userPreference;
    }

    // Default recommendation for South African users
    if (userLocation === 'ZA') {
      return 'ozow'; // Most user-friendly for SA
    }

    return 'stripe'; // Default fallback
  }

  /**
   * Verify payment status
   */
  async verifyPaymentStatus(provider, transactionId) {
    try {
      let status;

      switch (provider) {
        case 'stripe':
          status = await this.verifyStripePayment(transactionId);
          break;
        case 'snapscan':
          status = await this.verifySnapScanPayment(transactionId);
          break;
        case 'yoco':
          status = await this.verifyYocoPayment(transactionId);
          break;
        case 'payu':
          status = await this.verifyPayUPayment(transactionId);
          break;
        case 'payflex':
          status = await this.verifyPayFlexPayment(transactionId);
          break;
        case 'capitec':
          status = await this.verifyCapitecPayment(transactionId);
          break;
        case 'ozow':
          status = await this.verifyOzowPayment(transactionId);
          break;
        case 'paypal':
          status = await this.verifyPayPalPayment(transactionId);
          break;
        default:
          throw new Error(`Unknown payment provider: ${provider}`);
      }

      return status;
    } catch (error) {
      logger.error('Payment verification failed', {
        provider,
        transactionId,
        error: error.message,
      });
      throw error;
    }
  }

  /**
   * Mock API calls for development
   * In production, replace with actual API calls
   */
  async callSnapScanAPI(data) {
    // TODO: Implement SnapScan API integration
    return {
      id: `snap_${Date.now()}`,
      qrCode: 'qr_code_url',
      deepLink: `snapscan://pay/${data.amount}`,
    };
  }

  async callYocoAPI(data) {
    // TODO: Implement Yoco API integration
    return {
      id: `yoco_${Date.now()}`,
      status: 'pending',
    };
  }

  async callPayUAPI(data) {
    // TODO: Implement PayU API integration
    return {
      reference: `payu_${Date.now()}`,
      redirect_url: `https://secure.paygate.co.za/payu`,
      status: 'pending',
    };
  }

  async callPayFlexAPI(data) {
    // TODO: Implement PayFlex API integration
    return {
      id: `payflex_${Date.now()}`,
      checkout_url: `https://checkout.payflex.co.za/pay/${Date.now()}`,
      installments: data.installments,
    };
  }

  async callCapitecAPI(data) {
    // TODO: Implement Capitec API integration
    return {
      reference: `cap_${Date.now()}`,
      redirect_url: `https://capitec.co.za/pay`,
      status: 'pending',
    };
  }

  async callOzowAPI(data) {
    // TODO: Implement Ozow API integration
    return {
      id: `ozow_${Date.now()}`,
      redirect_url: `https://ozow.com/pay/${Date.now()}`,
      status: 'pending',
    };
  }

  async callPayPalAPI(data) {
    // TODO: Implement PayPal API integration
    return {
      id: `paypal_${Date.now()}`,
      approvalUrl: `https://www.paypal.com/checkoutnow?token=${Date.now()}`,
    };
  }

  async verifyStripePayment(paymentIntentId) {
    const intent = await stripe.paymentIntents.retrieve(paymentIntentId);
    return {
      status: intent.status,
      paid: intent.status === 'succeeded',
    };
  }

  async verifySnapScanPayment(transactionId) {
    // TODO: Implement SnapScan verification
    return {
      status: 'pending',
      paid: false,
    };
  }

  async verifyYocoPayment(transactionId) {
    // TODO: Implement Yoco verification
    return {
      status: 'pending',
      paid: false,
    };
  }

  async verifyPayUPayment(transactionId) {
    // TODO: Implement PayU verification
    return {
      status: 'pending',
      paid: false,
    };
  }

  async verifyPayFlexPayment(transactionId) {
    // TODO: Implement PayFlex verification
    return {
      status: 'pending',
      paid: false,
    };
  }

  async verifyCapitecPayment(transactionId) {
    // TODO: Implement Capitec verification
    return {
      status: 'pending',
      paid: false,
    };
  }

  async verifyOzowPayment(transactionId) {
    // TODO: Implement Ozow verification
    return {
      status: 'pending',
      paid: false,
    };
  }

  async verifyPayPalPayment(transactionId) {
    // TODO: Implement PayPal verification
    return {
      status: 'pending',
      paid: false,
    };
  }
}

module.exports = new SAPaymentService();
