/**
 * South African Payment Methods Configuration
 * 8 Local Payment Methods + International Options
 */

module.exports = {
  // Primary currency for South Africa
  primaryCurrency: 'ZAR',
  
  // All supported currencies
  supportedCurrencies: {
    ZAR: {
      name: 'South African Rand',
      symbol: 'R',
      code: 'ZAR',
    },
    USD: {
      name: 'US Dollar',
      symbol: '$',
      code: 'USD',
    },
    EUR: {
      name: 'Euro',
      symbol: '€',
      code: 'EUR',
    },
  },

  // 8 South African Payment Methods
  paymentMethods: {
    // 1. STRIPE (International Cards)
    stripe: {
      id: 'stripe',
      name: 'Stripe',
      category: 'international_cards',
      description: 'Visa, Mastercard, American Express',
      icon: '??',
      logo: 'stripe-logo.png',
      
      // Configuration
      enabled: true,
      currencies: ['ZAR', 'USD', 'EUR'],
      minAmount: 50, // ZAR
      maxAmount: 999999, // ZAR
      
      // Features
      features: {
        cardPayments: true,
        subscriptions: true,
        recurring: true,
        international: true,
      },
      
      // Pricing
      fee: {
        percentage: 2.9,
        fixed: 1.99, // ZAR
        description: '2.9% + R1.99',
      },
      
      // Processing
      processingTime: 'Instant',
      settlementTime: '1-2 business days',
      
      // Documentation
      docs: 'https://stripe.com/docs',
      apiKey: process.env.STRIPE_SECRET_KEY,
    },

    // 2. SNAPSCAN (QR Code Mobile Payments)
    snapscan: {
      id: 'snapscan',
      name: 'SnapScan',
      category: 'mobile_wallets',
      description: 'Instant mobile payments via QR code',
      icon: '??',
      logo: 'snapscan-logo.png',
      
      // Configuration
      enabled: true,
      currencies: ['ZAR'],
      minAmount: 0.50,
      maxAmount: 50000,
      
      // Features
      features: {
        qrCode: true,
        mobileOptimized: true,
        instantPayment: true,
        recurring: false,
        international: false,
      },
      
      // Pricing
      fee: {
        percentage: 1.5,
        fixed: 0,
        description: '1.5% of transaction',
      },
      
      // Processing
      processingTime: 'Instant',
      settlementTime: 'Same day',
      
      // Documentation
      docs: 'https://www.snapscan.io/developers',
      apiKey: process.env.SNAPSCAN_API_KEY,
    },

    // 3. YOCO (Card & Mobile Payments)
    yoco: {
      id: 'yoco',
      name: 'Yoco',
      category: 'card_mobile',
      description: 'Card & mobile payments for SA businesses',
      icon: '??',
      logo: 'yoco-logo.png',
      
      // Configuration
      enabled: true,
      currencies: ['ZAR'],
      minAmount: 1,
      maxAmount: 999999,
      
      // Features
      features: {
        cardPayments: true,
        mobilePayments: true,
        subscriptions: true,
        recurring: true,
        international: false,
      },
      
      // Pricing
      fee: {
        percentage: 2.5,
        fixed: 0,
        description: '2.5% of transaction',
      },
      
      // Processing
      processingTime: 'Instant',
      settlementTime: '1-2 business days',
      
      // Documentation
      docs: 'https://yoco.com/api-docs',
      apiKey: process.env.YOCO_API_KEY,
    },

    // 4. PAYU (Credit/Debit Card Gateway)
    payu: {
      id: 'payu',
      name: 'PayU',
      category: 'card_gateway',
      description: 'Major payment gateway for SA',
      icon: '??',
      logo: 'payu-logo.png',
      
      // Configuration
      enabled: true,
      currencies: ['ZAR'],
      minAmount: 1,
      maxAmount: 999999,
      
      // Features
      features: {
        cardPayments: true,
        bankTransfer: true,
        subscriptions: true,
        recurring: true,
        international: false,
      },
      
      // Pricing
      fee: {
        percentage: 2.85,
        fixed: 0,
        description: '2.85% of transaction',
      },
      
      // Processing
      processingTime: '5-30 seconds',
      settlementTime: '1 business day',
      
      // Documentation
      docs: 'https://www.payumoney.com/payu-sa-documentation',
      apiKey: process.env.PAYU_API_KEY,
    },

    // 5. PAYFLEX (Buy Now Pay Later - BNPL)
    payflex: {
      id: 'payflex',
      name: 'PayFlex',
      category: 'bnpl', // Buy Now Pay Later
      description: 'Split payment - 3/6/12 months interest-free',
      icon: '??',
      logo: 'payflex-logo.png',
      
      // Configuration
      enabled: true,
      currencies: ['ZAR'],
      minAmount: 500, // Minimum for BNPL
      maxAmount: 999999,
      
      // Features
      features: {
        bnpl: true,
        installments: [3, 6, 12],
        interestFree: true,
        cardRequired: true,
        recurring: false,
        international: false,
      },
      
      // Pricing
      fee: {
        percentage: 0, // No transaction fee
        fixed: 0,
        description: 'Merchant fees apply',
      },
      
      // Processing
      processingTime: 'Instant',
      settlementTime: '1-2 business days',
      
      // Installment options
      installments: {
        3: {
          months: 3,
          interest: 0,
          description: '3 equal installments - Interest free',
        },
        6: {
          months: 6,
          interest: 0,
          description: '6 equal installments - Interest free',
        },
        12: {
          months: 12,
          interest: 0,
          description: '12 equal installments - Interest free',
        },
      },
      
      // Documentation
      docs: 'https://www.payflex.co.za/developers',
      apiKey: process.env.PAYFLEX_API_KEY,
    },

    // 6. CAPITEC BANK (Direct Banking)
    capitec: {
      id: 'capitec',
      name: 'Capitec Bank',
      category: 'direct_banking',
      description: 'Direct payment from Capitec Bank account',
      icon: '??',
      logo: 'capitec-logo.png',
      
      // Configuration
      enabled: true,
      currencies: ['ZAR'],
      minAmount: 1,
      maxAmount: 999999,
      
      // Features
      features: {
        bankTransfer: true,
        directDebit: true,
        subscriptions: true,
        recurring: true,
        international: false,
      },
      
      // Pricing
      fee: {
        percentage: 1.5,
        fixed: 0,
        description: '1.5% of transaction',
      },
      
      // Processing
      processingTime: '5 minutes',
      settlementTime: 'Same day',
      
      // Documentation
      docs: 'https://www.capitec.co.za/business/api',
      apiKey: process.env.CAPITEC_API_KEY,
    },

    // 7. OZOW (Open Banking - All SA Banks)
    ozow: {
      id: 'ozow',
      name: 'Ozow',
      category: 'open_banking',
      description: 'Pay directly from any SA bank',
      icon: '??',
      logo: 'ozow-logo.png',
      
      // Configuration
      enabled: true,
      currencies: ['ZAR'],
      minAmount: 0.01,
      maxAmount: 999999,
      
      // Features
      features: {
        bankTransfer: true,
        eWallet: true,
        creditCard: true,
        debitCard: true,
        recurring: true,
        international: false,
      },
      
      // Supported Banks (All major SA banks)
      supportedBanks: [
        'ABSA',
        'FNB',
        'Nedbank',
        'Standard Bank',
        'Capitec',
        'Investec',
        'Bidvest',
        'Discovery',
      ],
      
      // Pricing
      fee: {
        percentage: 1.2,
        fixed: 0,
        description: '1.2% of transaction',
      },
      
      // Processing
      processingTime: '5 minutes',
      settlementTime: '1 business day',
      
      // Documentation
      docs: 'https://ozow.com/documentation',
      apiKey: process.env.OZOW_API_KEY,
    },

    // 8. PAYPAL (International Wallet)
    paypal: {
      id: 'paypal',
      name: 'PayPal',
      category: 'digital_wallet',
      description: 'PayPal wallet and account payments',
      icon: '??',
      logo: 'paypal-logo.png',
      
      // Configuration
      enabled: true,
      currencies: ['USD', 'ZAR'],
      minAmount: 10, // USD / ZAR equivalent
      maxAmount: 999999,
      
      // Features
      features: {
        walletPayment: true,
        cardPayment: true,
        bankTransfer: true,
        subscriptions: true,
        recurring: true,
        international: true,
      },
      
      // Pricing
      fee: {
        percentage: 3.49,
        fixed: 0.49, // USD / R equivalent
        description: '3.49% + R0.49 (or USD equivalent)',
      },
      
      // Processing
      processingTime: 'Instant',
      settlementTime: '1-2 business days',
      
      // Documentation
      docs: 'https://developer.paypal.com',
      apiKey: process.env.PAYPAL_CLIENT_ID,
    },
  },

  // Payment method categories with descriptions
  categories: {
    international_cards: {
      name: 'International Cards',
      description: 'Visa, Mastercard, American Express',
      methods: ['stripe'],
    },
    mobile_wallets: {
      name: 'Mobile Wallets',
      description: 'Quick mobile payments',
      methods: ['snapscan'],
    },
    card_mobile: {
      name: 'Cards & Mobile',
      description: 'Combined card and mobile solutions',
      methods: ['yoco'],
    },
    card_gateway: {
      name: 'Card Gateways',
      description: 'Traditional payment gateways',
      methods: ['payu'],
    },
    bnpl: {
      name: 'Buy Now Pay Later',
      description: 'Split payments with no interest',
      methods: ['payflex'],
    },
    direct_banking: {
      name: 'Direct Banking',
      description: 'Direct bank account access',
      methods: ['capitec'],
    },
    open_banking: {
      name: 'Open Banking',
      description: 'Pay from any SA bank',
      methods: ['ozow'],
    },
    digital_wallet: {
      name: 'Digital Wallets',
      description: 'International digital wallets',
      methods: ['paypal'],
    },
  },

  // Display order (frontend)
  displayOrder: [
    'ozow', // Most user-friendly for SA
    'snapscan', // Quick mobile payments
    'payflex', // Popular BNPL
    'yoco', // Local payment processor
    'capitec', // Direct banking
    'payu', // Major gateway
    'stripe', // International cards
    'paypal', // International wallet
  ],

  // Default payment method per user type
  defaults: {
    localUser: 'ozow', // Best for South African users
    internationalUser: 'stripe', // Best for international
    businessUser: 'yoco', // Best for businesses
    budgetConsciousUser: 'payflex', // BNPL option
  },

  // Environment variables required
  requiredEnvVars: [
    'STRIPE_SECRET_KEY',
    'SNAPSCAN_API_KEY',
    'YOCO_API_KEY',
    'PAYU_API_KEY',
    'PAYFLEX_API_KEY',
    'CAPITEC_API_KEY',
    'OZOW_API_KEY',
    'PAYPAL_CLIENT_ID',
  ],

  // Webhook endpoints for payment updates
  webhooks: {
    stripe: process.env.STRIPE_WEBHOOK_SECRET,
    snapscan: process.env.SNAPSCAN_WEBHOOK_SECRET,
    yoco: process.env.YOCO_WEBHOOK_SECRET,
    payu: process.env.PAYU_WEBHOOK_SECRET,
    payflex: process.env.PAYFLEX_WEBHOOK_SECRET,
    capitec: process.env.CAPITEC_WEBHOOK_SECRET,
    ozow: process.env.OZOW_WEBHOOK_SECRET,
    paypal: process.env.PAYPAL_WEBHOOK_SECRET,
  },

  // Error handling
  errorMessages: {
    insufficient_funds: 'Insufficient funds in account',
    card_declined: 'Card was declined',
    invalid_amount: 'Invalid payment amount',
    payment_timeout: 'Payment processing timeout',
    authentication_failed: 'Payment authentication failed',
    invalid_currency: 'Currency not supported for this method',
    bank_not_supported: 'Bank not supported',
  },
};
