/**
 * MonitoringSetup - Configure Sentry, New Relic, and custom monitoring
 */

const Sentry = require('@sentry/node');
const newrelic = require('newrelic');

class MonitoringSetup {
  /**
   * Initialize Sentry for error tracking
   */
  static initializeSentry(app) {
    const dsn = process.env.SENTRY_DSN;
    
    if (!dsn) {
      console.warn('⚠️  SENTRY_DSN not set. Error tracking disabled.');
      return;
    }

    Sentry.init({
      dsn,
      environment: process.env.NODE_ENV,
      tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
      integrations: [
        new Sentry.Integrations.Http({ tracing: true }),
        new Sentry.Integrations.Express({ app, request: true, serverName: true }),
        new Sentry.Integrations.OnUncaughtException(),
        new Sentry.Integrations.OnUnhandledRejection(),
      ],
      beforeSend: (event, hint) => {
        // Filter sensitive information
        if (event.request) {
          delete event.request.cookies;
          delete event.request.headers['authorization'];
        }
        return event;
      },
      debug: process.env.NODE_ENV !== 'production',
    });

    // Attach Sentry middleware
    app.use(Sentry.Handlers.requestHandler());
    app.use(Sentry.Handlers.errorHandler());

    console.log('✅ Sentry Error Tracking initialized');
  }

  /**
   * Initialize New Relic APM
   */
  static initializeNewRelic() {
    if (!process.env.NEW_RELIC_LICENSE_KEY) {
      console.warn('⚠️  NEW_RELIC_LICENSE_KEY not set. Performance monitoring disabled.');
      return;
    }

    // newrelic module is already loaded if imported
    console.log('✅ New Relic APM initialized');
  }

  /**
   * Setup custom metrics and dashboard
   */
  static setupCustomMetrics(app, io, db) {
    const metrics = {
      apiRequests: 0,
      activeConnections: 0,
      errorCount: 0,
      databaseQueries: 0,
      socketEvents: 0,
      paymentTransactions: 0,
      storyCreations: 0,
      messagesSent: 0,
    };

    // Track API requests
    app.use((req, res, next) => {
      metrics.apiRequests++;
      
      const start = Date.now();
      res.on('finish', () => {
        const duration = Date.now() - start;
        
        // Record in Sentry
        if (process.env.SENTRY_DSN) {
          Sentry.captureMessage(`API ${req.method} ${req.path}`, 'info');
        }

        // Log slow requests
        if (duration > 1000) {
          console.warn(`⚠️  SLOW REQUEST: ${req.method} ${req.path} - ${duration}ms`);
        }
      });

      next();
    });

    // Track socket connections
    io.on('connection', (socket) => {
      metrics.activeConnections++;
      
      socket.on('disconnect', () => {
        metrics.activeConnections--;
      });

      socket.onAny((event) => {
        metrics.socketEvents++;
      });
    });

    // Track custom events
    const eventTracker = {
      trackPayment: (amount, tier) => {
        metrics.paymentTransactions++;
        if (process.env.SENTRY_DSN) {
          Sentry.captureMessage(`Payment: ${amount} - ${tier}`, 'info');
        }
      },
      trackStoryCreation: () => {
        metrics.storyCreations++;
      },
      trackMessageSent: () => {
        metrics.messagesSent++;
      },
      trackError: (error, context = {}) => {
        metrics.errorCount++;
        if (process.env.SENTRY_DSN) {
          Sentry.captureException(error, { contexts: { custom: context } });
        }
      },
    };

    // Expose metrics endpoint
    app.get('/metrics', (req, res) => {
      res.json({
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        memory: {
          heapUsed: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
          heapTotal: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
          rss: Math.round(process.memoryUsage().rss / 1024 / 1024),
        },
        metrics,
      });
    });

    console.log('✅ Custom Metrics Setup initialized');

    return eventTracker;
  }

  /**
   * Setup health checks
   */
  static setupHealthChecks(app, db) {
    const checks = {};

    // Database health
    checks.database = async () => {
      try {
        await db.connection.db.admin().ping();
        return { status: 'healthy' };
      } catch (err) {
        return { status: 'unhealthy', error: err.message };
      }
    };

    // Memory health
    checks.memory = () => {
      const usage = process.memoryUsage();
      const heapPercent = (usage.heapUsed / usage.heapTotal) * 100;
      
      return {
        status: heapPercent > 90 ? 'warning' : 'healthy',
        heapUsedPercent: Math.round(heapPercent),
      };
    };

    // Disk health (if using node-os-utils)
    checks.disk = async () => {
      try {
        const osu = require('node-os-utils');
        const drive = osu.drive;
        const diskInfo = await drive.info();
        const used = diskInfo.usedPercentage;

        return {
          status: used > 90 ? 'warning' : 'healthy',
          usedPercent: Math.round(used),
        };
      } catch (err) {
        return { status: 'unknown', error: 'Disk check unavailable' };
      }
    };

    // Combined health endpoint
    app.get('/health', async (req, res) => {
      try {
        const results = {
          status: 'healthy',
          timestamp: new Date().toISOString(),
          checks: {},
        };

        // Run database check
        results.checks.database = await checks.database();

        // Run memory check
        results.checks.memory = checks.memory();

        // Run disk check
        results.checks.disk = await checks.disk();

        // Determine overall status
        const allStatuses = Object.values(results.checks).map(c => c.status);
        if (allStatuses.includes('unhealthy')) {
          results.status = 'unhealthy';
        } else if (allStatuses.includes('warning')) {
          results.status = 'warning';
        }

        const statusCode = results.status === 'healthy' ? 200 : 503;
        res.status(statusCode).json(results);
      } catch (err) {
        res.status(500).json({
          status: 'error',
          message: err.message,
        });
      }
    });

    console.log('✅ Health Checks Setup initialized');
  }

  /**
   * Setup performance monitoring
   */
  static setupPerformanceMonitoring(app) {
    const perfMonitoring = {
      endpoints: {},
    };

    // Middleware to track endpoint performance
    app.use((req, res, next) => {
      const start = Date.now();
      const originalJson = res.json;

      res.json = function(data) {
        const duration = Date.now() - start;
        const endpoint = `${req.method} ${req.route?.path || req.path}`;

        if (!perfMonitoring.endpoints[endpoint]) {
          perfMonitoring.endpoints[endpoint] = {
            count: 0,
            totalTime: 0,
            avgTime: 0,
            minTime: Infinity,
            maxTime: 0,
            errorCount: 0,
          };
        }

        const stats = perfMonitoring.endpoints[endpoint];
        stats.count++;
        stats.totalTime += duration;
        stats.avgTime = Math.round(stats.totalTime / stats.count);
        stats.minTime = Math.min(stats.minTime, duration);
        stats.maxTime = Math.max(stats.maxTime, duration);

        if (res.statusCode >= 400) {
          stats.errorCount++;
        }

        // Alert on slow endpoints
        if (duration > 2000) {
          console.warn(`⚠️  SLOW ENDPOINT: ${endpoint} took ${duration}ms`);
          if (process.env.SENTRY_DSN) {
            Sentry.captureMessage(
              `Slow endpoint: ${endpoint} - ${duration}ms`,
              'warning'
            );
          }
        }

        return originalJson.call(this, data);
      };

      next();
    });

    // Performance stats endpoint
    app.get('/performance-stats', (req, res) => {
      res.json(perfMonitoring);
    });

    console.log('✅ Performance Monitoring Setup initialized');
  }

  /**
   * Setup log aggregation markers
   */
  static setupLogAggregation() {
    const originalLog = console.log;
    const originalWarn = console.warn;
    const originalError = console.error;

    // Structured logging
    console.log = function(...args) {
      const timestamp = new Date().toISOString();
      originalLog(`[${timestamp}] [INFO]`, ...args);
    };

    console.warn = function(...args) {
      const timestamp = new Date().toISOString();
      originalWarn(`[${timestamp}] [WARN]`, ...args);
    };

    console.error = function(...args) {
      const timestamp = new Date().toISOString();
      originalError(`[${timestamp}] [ERROR]`, ...args);
    };

    console.log('✅ Log Aggregation Setup initialized');
  }

  /**
   * Setup alerting thresholds
   */
  static getAlertingConfig() {
    return {
      errorRate: {
        threshold: 1, // percent
        window: 300000, // 5 minutes
        action: 'page',
      },
      responseTime: {
        threshold: 500, // ms (p95)
        window: 60000, // 1 minute
        action: 'page',
      },
      memoryUsage: {
        threshold: 80, // percent
        window: 60000,
        action: 'notify',
      },
      databaseLatency: {
        threshold: 200, // ms
        window: 60000,
        action: 'notify',
      },
      socketConnectionDrops: {
        threshold: 5, // drops per minute
        window: 60000,
        action: 'notify',
      },
      paymentFailureRate: {
        threshold: 5, // percent
        window: 3600000, // 1 hour
        action: 'page',
      },
    };
  }
}

module.exports = MonitoringSetup;
