/**
 * ProductionBootstrap - Integration of all production modules
 * Initializes: Secrets, Security, Monitoring, and Health Checks
 * 
 * Usage in server.js:
 * const ProductionBootstrap = require('./lib/production_bootstrap');
 * ProductionBootstrap.initializeProduction(app, io, db);
 */

const SecretsManager = require('./secrets_manager');
const SecurityHardening = require('./security_hardening');
const MonitoringSetup = require('./monitoring_setup');

class ProductionBootstrap {
  /**
   * Initialize all production systems
   * Must be called after app creation but before route definition
   */
  static initializeProduction(app, io, db) {
    console.log('\n' + '═'.repeat(60));
    console.log('🚀 INITIALIZING MEENGLE PRODUCTION ENVIRONMENT');
    console.log('═'.repeat(60) + '\n');

    try {
      // Step 1: Initialize Secrets
      this.initializeSecrets();

      // Step 2: Apply Security
      this.initializeSecurity(app, io);

      // Step 3: Setup Monitoring
      this.initializeMonitoring(app, io, db);

      // Step 4: Verify Status
      this.verifyProductionReady();

      console.log('\n' + '═'.repeat(60));
      console.log('✅ PRODUCTION BOOTSTRAP COMPLETE');
      console.log('═'.repeat(60) + '\n');

      return true;
    } catch (err) {
      console.error('\n' + '═'.repeat(60));
      console.error('❌ PRODUCTION BOOTSTRAP FAILED');
      console.error('═'.repeat(60));
      console.error(err.message);
      console.error('═'.repeat(60) + '\n');
      process.exit(1);
    }
  }

  /**
   * Step 1: Initialize and validate secrets
   */
  static initializeSecrets() {
    console.log('\n📋 STEP 1: Initializing Secrets Manager');
    console.log('─'.repeat(60));

    try {
      SecretsManager.initialize();
      
      // Validate production environment
      if (process.env.NODE_ENV === 'production') {
        SecretsManager.validateProduction();
      }

      // Validate secret formats
      SecretsManager.validateFormat();

      console.log('✅ Secrets Manager initialized successfully\n');
    } catch (err) {
      throw new Error(`Secrets initialization failed: ${err.message}`);
    }
  }

  /**
   * Step 2: Apply security hardening
   */
  static initializeSecurity(app, io) {
    console.log('🔒 STEP 2: Applying Security Hardening');
    console.log('─'.repeat(60));

    try {
      const security = new SecurityHardening(app, io);
      security.applyAll();
      security.verifyHeaders();

      console.log('✅ Security hardening applied successfully\n');
    } catch (err) {
      throw new Error(`Security initialization failed: ${err.message}`);
    }
  }

  /**
   * Step 3: Setup monitoring and alerting
   */
  static initializeMonitoring(app, io, db) {
    console.log('📊 STEP 3: Setting Up Monitoring & Alerting');
    console.log('─'.repeat(60));

    try {
      // Initialize error tracking
      MonitoringSetup.initializeSentry(app);

      // Initialize APM
      MonitoringSetup.initializeNewRelic();

      // Setup custom metrics
      const eventTracker = MonitoringSetup.setupCustomMetrics(app, io, db);
      global.eventTracker = eventTracker; // Make available globally

      // Setup health checks
      MonitoringSetup.setupHealthChecks(app, db);

      // Setup performance monitoring
      MonitoringSetup.setupPerformanceMonitoring(app);

      // Setup logging
      MonitoringSetup.setupLogAggregation();

      console.log('✅ Monitoring & Alerting setup complete\n');
    } catch (err) {
      throw new Error(`Monitoring initialization failed: ${err.message}`);
    }
  }

  /**
   * Verify production readiness
   */
  static verifyProductionReady() {
    console.log('✔️  STEP 4: Verifying Production Readiness');
    console.log('─'.repeat(60));

    const checks = {
      environment: process.env.NODE_ENV,
      nodeVersion: process.version,
      secrets: {
        mongodb: !!SecretsManager.get('mongodbUri'),
        jwt: !!SecretsManager.get('jwtSecret'),
        stripe: !!SecretsManager.get('stripeSecretKey'),
        firebase: !!SecretsManager.get('firebaseProjectId'),
      },
      ports: {
        api: process.env.PORT || 3001,
      },
      timestamp: new Date().toISOString(),
    };

    console.log('\nProduction Status:');
    console.log('  Environment:', checks.environment);
    console.log('  Node Version:', checks.nodeVersion);
    console.log('\nSecrets Loaded:');
    console.log('  MongoDB:', checks.secrets.mongodb ? '✅' : '❌');
    console.log('  JWT:', checks.secrets.jwt ? '✅' : '❌');
    console.log('  Stripe:', checks.secrets.stripe ? '✅' : '❌');
    console.log('  Firebase:', checks.secrets.firebase ? '✅' : '❌');
    console.log('\nEndpoints Available:');
    console.log('  API Port:', checks.ports.api);
    console.log('  Health Check: /health');
    console.log('  Metrics: /metrics');
    console.log('  Performance: /performance-stats');

    // Critical failure checks
    if (!checks.secrets.mongodb) {
      throw new Error('CRITICAL: MongoDB URI not configured');
    }
    if (process.env.NODE_ENV === 'production') {
      if (!checks.secrets.jwt) throw new Error('CRITICAL: JWT_SECRET not set');
      if (!checks.secrets.stripe) throw new Error('CRITICAL: STRIPE_SECRET_KEY not set');
      if (!checks.secrets.firebase) throw new Error('CRITICAL: FIREBASE_PROJECT_ID not set');
    }

    console.log('\n✅ All production checks passed\n');
  }

  /**
   * Get production readiness report
   */
  static getReadinessReport() {
    return {
      timestamp: new Date().toISOString(),
      status: process.env.NODE_ENV,
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      environment: {
        node: process.version,
        platform: process.platform,
        arch: process.arch,
      },
      secrets: SecretsManager.getAll(true),
      endpoints: {
        health: '/health',
        metrics: '/metrics',
        performanceStats: '/performance-stats',
      },
      checks: {
        mongodb: SecretsManager.get('mongodbUri') ? 'configured' : 'missing',
        jwt: SecretsManager.get('jwtSecret') ? 'configured' : 'missing',
        stripe: SecretsManager.get('stripeSecretKey') ? 'configured' : 'missing',
        firebase: SecretsManager.get('firebaseProjectId') ? 'configured' : 'missing',
      },
    };
  }

  /**
   * Production deployment instructions
   */
  static printDeploymentInstructions() {
    console.log('\n' + '═'.repeat(60));
    console.log('📋 DEPLOYMENT INSTRUCTIONS');
    console.log('═'.repeat(60) + '\n');

    console.log('1. PRE-DEPLOYMENT CHECKLIST:');
    console.log('   [ ] Review DEPLOYMENT_CHECKLIST.md');
    console.log('   [ ] All secrets configured in .env.production');
    console.log('   [ ] Database backups verified');
    console.log('   [ ] SSL certificate installed');
    console.log('   [ ] Load balancer configured');

    console.log('\n2. ENVIRONMENT SETUP:');
    console.log('   $ cp .env.production.template .env.production');
    console.log('   $ export $(cat .env.production | xargs)');
    console.log('   $ npm install --production');
    console.log('   $ npm run migrate:prod');

    console.log('\n3. START SERVICES:');
    console.log('   $ npm start');
    console.log('   Server listening on port:', process.env.PORT || 3001);

    console.log('\n4. VERIFY DEPLOYMENT:');
    console.log('   $ curl https://api.meengle.app/health');
    console.log('   $ curl https://api.meengle.app/metrics');

    console.log('\n5. MONITORING:');
    console.log('   Dashboard: https://dashboard.sentry.io (Sentry)');
    console.log('   Alerts: Configured in NewRelic');
    console.log('   Logs: Aggregated via ELK/CloudWatch');

    console.log('\n6. ESCALATION CONTACTS:');
    console.log('   On-Call: [Phone/Email]');
    console.log('   CTO: [Contact Info]');
    console.log('   DevOps: [Contact Info]');

    console.log('\n' + '═'.repeat(60) + '\n');
  }
}

module.exports = ProductionBootstrap;
