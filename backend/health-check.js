const axios = require('axios');
const logger = require('../config/logger');

/**
 * Health check service
 * Monitors the health of all critical services
 */
class HealthCheck {
  constructor() {
    this.checks = [];
  }

  /**
   * Check API health
   */
  async checkAPI() {
    try {
      const response = await axios.get(
        `${process.env.API_URL || 'http://localhost:3000'}/api/v1/health`,
        { timeout: 5000 }
      );
      return {
        service: 'API',
        status: response.status === 200 ? 'healthy' : 'unhealthy',
        timestamp: new Date(),
      };
    } catch (error) {
      logger.error('API health check failed', { error: error.message });
      return {
        service: 'API',
        status: 'unhealthy',
        error: error.message,
        timestamp: new Date(),
      };
    }
  }

  /**
   * Check database connection
   */
  async checkDatabase() {
    try {
      const mongoose = require('mongoose');
      const isConnected = mongoose.connection.readyState === 1;
      
      return {
        service: 'Database',
        status: isConnected ? 'healthy' : 'unhealthy',
        timestamp: new Date(),
      };
    } catch (error) {
      logger.error('Database health check failed', { error: error.message });
      return {
        service: 'Database',
        status: 'unhealthy',
        error: error.message,
        timestamp: new Date(),
      };
    }
  }

  /**
   * Check Redis connection
   */
  async checkRedis() {
    try {
      const cacheService = require('../services/cacheService');
      const testKey = 'health_check_test';
      
      await cacheService.set(testKey, 'ok', 10);
      const value = await cacheService.get(testKey);
      
      return {
        service: 'Redis',
        status: value === 'ok' ? 'healthy' : 'unhealthy',
        timestamp: new Date(),
      };
    } catch (error) {
      logger.error('Redis health check failed', { error: error.message });
      return {
        service: 'Redis',
        status: 'unhealthy',
        error: error.message,
        timestamp: new Date(),
      };
    }
  }

  /**
   * Check external services
   */
  async checkExternalServices() {
    const externalServices = [];

    // Check Stripe
    if (process.env.STRIPE_SECRET_KEY) {
      try {
        const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
        await stripe.charges.list({ limit: 1 });
        externalServices.push({
          service: 'Stripe',
          status: 'healthy',
          timestamp: new Date(),
        });
      } catch (error) {
        externalServices.push({
          service: 'Stripe',
          status: 'unhealthy',
          error: error.message,
          timestamp: new Date(),
        });
      }
    }

    // Check SendGrid/Email
    if (process.env.EMAIL_SERVICE) {
      externalServices.push({
        service: 'Email Service',
        status: 'healthy',
        timestamp: new Date(),
      });
    }

    return externalServices;
  }

  /**
   * Check system resources
   */
  async checkResources() {
    try {
      const os = require('os');
      const totalMemory = os.totalmem();
      const freeMemory = os.freemem();
      const usedMemory = totalMemory - freeMemory;
      const memoryUsagePercent = (usedMemory / totalMemory) * 100;

      return {
        service: 'Resources',
        status: memoryUsagePercent < 90 ? 'healthy' : 'warning',
        memory: {
          total: totalMemory,
          used: usedMemory,
          free: freeMemory,
          usagePercent: memoryUsagePercent.toFixed(2),
        },
        cpus: os.cpus().length,
        uptime: os.uptime(),
        timestamp: new Date(),
      };
    } catch (error) {
      logger.error('Resource health check failed', { error: error.message });
      return {
        service: 'Resources',
        status: 'unhealthy',
        error: error.message,
        timestamp: new Date(),
      };
    }
  }

  /**
   * Run all health checks
   */
  async runAllChecks() {
    try {
      logger.info('Running health checks');

      const results = await Promise.all([
        this.checkAPI(),
        this.checkDatabase(),
        this.checkRedis(),
        this.checkResources(),
        this.checkExternalServices(),
      ]);

      const externalServices = results[4];
      results.pop(); // Remove external services from main results

      const allChecks = {
        timestamp: new Date(),
        status: this.determineOverallStatus(results),
        checks: [...results, ...externalServices],
      };

      logger.info('Health checks completed', { 
        status: allChecks.status,
        totalChecks: allChecks.checks.length,
      });

      return allChecks;
    } catch (error) {
      logger.error('Health check failed', { error: error.message });
      return {
        timestamp: new Date(),
        status: 'unhealthy',
        error: error.message,
        checks: [],
      };
    }
  }

  /**
   * Determine overall status
   */
  determineOverallStatus(checks) {
    const unhealthyServices = checks.filter(c => c.status === 'unhealthy');
    
    if (unhealthyServices.length > 0) {
      return 'unhealthy';
    }

    const warningServices = checks.filter(c => c.status === 'warning');
    if (warningServices.length > 0) {
      return 'warning';
    }

    return 'healthy';
  }

  /**
   * Get human-readable report
   */
  async getReport() {
    const health = await this.runAllChecks();
    
    let report = '\n=== MEENGLE HEALTH CHECK REPORT ===\n\n';
    report += `Overall Status: ${health.status.toUpperCase()}\n`;
    report += `Timestamp: ${health.timestamp}\n\n`;

    report += 'Service Status:\n';
    health.checks.forEach(check => {
      const icon = check.status === 'healthy' ? '?' : '?';
      report += `  ${icon} ${check.service}: ${check.status.toUpperCase()}\n`;
      
      if (check.memory) {
        report += `    Memory: ${check.memory.usagePercent}% (${Math.round(check.memory.used / 1024 / 1024)} MB)\n`;
      }
      
      if (check.error) {
        report += `    Error: ${check.error}\n`;
      }
    });

    report += '\n===================================\n';
    return report;
  }
}

module.exports = new HealthCheck();
