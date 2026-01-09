/**
 * SecretsManager - Handles all sensitive credentials and secrets
 * Uses environment variables with validation
 */

class SecretsManager {
  constructor() {
    this.secrets = {};
    this.validated = false;
  }

  /**
   * Initialize and validate all required secrets
   */
  initialize() {
    this.secrets = {
      // Database
      mongodbUri: this.getSecret('MONGODB_URI', 'mongodb://localhost:27017/meengle'),
      redisUrl: this.getSecret('REDIS_URL', 'redis://localhost:6379'),

      // Authentication
      jwtSecret: this.getSecret('JWT_SECRET', null, true),
      jwtRefreshSecret: this.getSecret('JWT_REFRESH_SECRET', null, true),

      // Stripe Payment
      stripeSecretKey: this.getSecret('STRIPE_SECRET_KEY', null, true),
      stripePublishableKey: this.getSecret('STRIPE_PUBLISHABLE_KEY', null, true),
      stripeWebhookSecret: this.getSecret('STRIPE_WEBHOOK_SECRET', null, true),

      // Firebase
      firebaseProjectId: this.getSecret('FIREBASE_PROJECT_ID', null, true),
      firebaseApiKey: this.getSecret('FIREBASE_API_KEY', null, true),
      firebaseServiceAccountKey: this.getSecret('FIREBASE_SERVICE_ACCOUNT_KEY', null, true),

      // AWS (if using S3 for storage)
      awsAccessKeyId: this.getSecret('AWS_ACCESS_KEY_ID'),
      awsSecretAccessKey: this.getSecret('AWS_SECRET_ACCESS_KEY'),
      awsRegion: this.getSecret('AWS_REGION', 'us-east-1'),
      awsBucketName: this.getSecret('AWS_BUCKET_NAME'),

      // Monitoring
      sentryDsn: this.getSecret('SENTRY_DSN'),
      newRelicLicenseKey: this.getSecret('NEW_RELIC_LICENSE_KEY'),

      // Email Service
      sendgridApiKey: this.getSecret('SENDGRID_API_KEY'),
      sendgridFromEmail: this.getSecret('SENDGRID_FROM_EMAIL', 'noreply@meengle.app'),

      // External Services
      twilioAccountSid: this.getSecret('TWILIO_ACCOUNT_SID'),
      twilioAuthToken: this.getSecret('TWILIO_AUTH_TOKEN'),
      twilioPhoneNumber: this.getSecret('TWILIO_PHONE_NUMBER'),

      // Environment
      nodeEnv: this.getSecret('NODE_ENV', 'development'),
      port: this.getSecret('PORT', '3001'),
      clientUrl: this.getSecret('CLIENT_URL', 'http://localhost:3000'),
    };

    this.validated = true;
    this.logValidation();
  }

  /**
   * Get a secret from environment variables
   * @param {string} key - Environment variable name
   * @param {string} defaultValue - Default value if not found
   * @param {boolean} required - Whether this secret is required
   * @returns {string} Secret value
   */
  getSecret(key, defaultValue = null, required = false) {
    const value = process.env[key];

    if (!value) {
      if (required) {
        throw new Error(
          `CRITICAL: Required secret not found: ${key}. ` +
          `Set the environment variable and restart the server.`
        );
      }
      if (defaultValue === null) {
        console.warn(`⚠️  WARNING: Optional secret not set: ${key}`);
      }
      return defaultValue;
    }

    return value;
  }

  /**
   * Get a secret by key
   * @param {string} key - Secret key
   * @returns {string} Secret value
   */
  get(key) {
    if (!this.validated) {
      throw new Error('SecretsManager not initialized. Call initialize() first.');
    }
    return this.secrets[key];
  }

  /**
   * Rotate JWT secret (should be called periodically)
   * @param {string} newSecret - New JWT secret
   */
  rotateJwtSecret(newSecret) {
    if (!newSecret || newSecret.length < 32) {
      throw new Error('JWT secret must be at least 32 characters long');
    }
    this.secrets.jwtSecret = newSecret;
    console.log('✅ JWT secret rotated successfully');
  }

  /**
   * Rotate Stripe webhook secret
   * @param {string} newSecret - New webhook secret from Stripe
   */
  rotateStripeWebhookSecret(newSecret) {
    if (!newSecret) {
      throw new Error('Stripe webhook secret cannot be empty');
    }
    this.secrets.stripeWebhookSecret = newSecret;
    console.log('✅ Stripe webhook secret rotated successfully');
  }

  /**
   * Validate all critical secrets are set
   */
  validateProduction() {
    const criticalSecrets = [
      'jwtSecret',
      'stripeSecretKey',
      'stripeWebhookSecret',
      'firebaseProjectId',
      'firebaseServiceAccountKey',
    ];

    const missing = [];
    for (const secret of criticalSecrets) {
      if (!this.secrets[secret]) {
        missing.push(secret);
      }
    }

    if (missing.length > 0) {
      throw new Error(
        `PRODUCTION: Missing critical secrets: ${missing.join(', ')}. ` +
        `Cannot start server in production without these secrets.`
      );
    }

    console.log('✅ All critical production secrets validated');
  }

  /**
   * Log validation status (masks sensitive values)
   */
  logValidation() {
    console.log('\n📋 Secret Configuration Status:');
    console.log('━'.repeat(50));

    const categories = {
      'Database': ['mongodbUri', 'redisUrl'],
      'Authentication': ['jwtSecret', 'jwtRefreshSecret'],
      'Payments': ['stripeSecretKey', 'stripeWebhookSecret'],
      'Firebase': ['firebaseProjectId', 'firebaseServiceAccountKey'],
      'AWS': ['awsAccessKeyId', 'awsBucketName'],
      'Monitoring': ['sentryDsn', 'newRelicLicenseKey'],
      'Email': ['sendgridApiKey'],
      'Messaging': ['twilioAccountSid'],
    };

    for (const [category, keys] of Object.entries(categories)) {
      const status = keys.map(key => {
        const value = this.secrets[key];
        return value ? `✅ ${key}` : `❌ ${key}`;
      });
      console.log(`\n${category}:`);
      status.forEach(s => console.log(`  ${s}`));
    }

    console.log('\n' + '━'.repeat(50) + '\n');
  }

  /**
   * Get all secrets (for internal use only, masks sensitive data in logs)
   */
  getAll(maskSensitive = true) {
    if (!maskSensitive) {
      return { ...this.secrets };
    }

    const masked = { ...this.secrets };
    const sensitiveKeys = [
      'jwtSecret',
      'jwtRefreshSecret',
      'stripeSecretKey',
      'stripeWebhookSecret',
      'firebaseServiceAccountKey',
      'awsSecretAccessKey',
      'sendgridApiKey',
      'twilioAuthToken',
    ];

    for (const key of sensitiveKeys) {
      if (masked[key]) {
        masked[key] = '***MASKED***';
      }
    }

    return masked;
  }

  /**
   * Validate secret format
   */
  validateFormat() {
    const validations = {
      jwtSecret: (val) => val && val.length >= 32,
      stripeSecretKey: (val) => val && val.startsWith('sk_'),
      stripePublishableKey: (val) => val && val.startsWith('pk_'),
      mongodbUri: (val) => val && val.includes('mongodb'),
      firebaseProjectId: (val) => val && val.length > 0,
    };

    for (const [key, validator] of Object.entries(validations)) {
      if (this.secrets[key] && !validator(this.secrets[key])) {
        console.warn(`⚠️  WARNING: Secret format may be incorrect: ${key}`);
      }
    }
  }
}

module.exports = new SecretsManager();
