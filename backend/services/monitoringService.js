import fs from 'fs';
import path from 'path';

const LOGS_DIR = process.env.LOGS_DIR || './logs';

if (!fs.existsSync(LOGS_DIR)) {
  fs.mkdirSync(LOGS_DIR, { recursive: true });
}

const LOG_LEVELS = {
  ERROR: 'ERROR',
  WARN: 'WARN',
  INFO: 'INFO',
  DEBUG: 'DEBUG'
};

const getLogFileName = (level) => {
  const date = new Date().toISOString().split('T')[0];
  return path.join(LOGS_DIR, `${level.toLowerCase()}-${date}.log`);
};

const formatLog = (level, message, data) => {
  const timestamp = new Date().toISOString();
  const dataStr = data ? JSON.stringify(data) : '';
  return `[${timestamp}] ${level}: ${message} ${dataStr}\n`;
};

export const logger = {
  error: (message, data) => {
    const logEntry = formatLog(LOG_LEVELS.ERROR, message, data);
    console.error(logEntry);
    fs.appendFileSync(getLogFileName('error'), logEntry);
  },

  warn: (message, data) => {
    const logEntry = formatLog(LOG_LEVELS.WARN, message, data);
    console.warn(logEntry);
    fs.appendFileSync(getLogFileName('warn'), logEntry);
  },

  info: (message, data) => {
    const logEntry = formatLog(LOG_LEVELS.INFO, message, data);
    console.log(logEntry);
    fs.appendFileSync(getLogFileName('info'), logEntry);
  },

  debug: (message, data) => {
    if (process.env.DEBUG === 'true') {
      const logEntry = formatLog(LOG_LEVELS.DEBUG, message, data);
      console.log(logEntry);
      fs.appendFileSync(getLogFileName('debug'), logEntry);
    }
  }
};

export const logMiddleware = (req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    const logData = {
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
      userId: req.userId || 'anonymous'
    };

    if (res.statusCode >= 400) {
      logger.warn(`HTTP ${res.statusCode}`, logData);
    } else {
      logger.info(`HTTP ${res.statusCode}`, logData);
    }
  });

  next();
};

export const errorLogger = (err, req, res, next) => {
  const errorData = {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    ip: req.ip,
    userId: req.userId || 'anonymous'
  };

  logger.error('Unhandled error', errorData);
  next(err);
};

export class MetricsCollector {
  constructor() {
    this.metrics = {
      requests: 0,
      errors: 0,
      avgResponseTime: 0,
      statusCodes: {},
      endpoints: {}
    };
  }

  recordRequest(method, path, status, duration) {
    this.metrics.requests++;

    if (status >= 400) {
      this.metrics.errors++;
    }

    this.metrics.statusCodes[status] = (this.metrics.statusCodes[status] || 0) + 1;

    const endpoint = `${method} ${path}`;
    if (!this.metrics.endpoints[endpoint]) {
      this.metrics.endpoints[endpoint] = { count: 0, totalTime: 0 };
    }
    this.metrics.endpoints[endpoint].count++;
    this.metrics.endpoints[endpoint].totalTime += duration;
  }

  getMetrics() {
    const sortedEndpoints = Object.entries(this.metrics.endpoints)
      .map(([endpoint, data]) => ({
        endpoint,
        count: data.count,
        avgTime: Math.round(data.totalTime / data.count)
      }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10);

    return {
      totalRequests: this.metrics.requests,
      totalErrors: this.metrics.errors,
      errorRate: `${((this.metrics.errors / Math.max(this.metrics.requests, 1)) * 100).toFixed(2)}%`,
      statusCodes: this.metrics.statusCodes,
      topEndpoints: sortedEndpoints,
      uptime: process.uptime()
    };
  }

  reset() {
    this.metrics = {
      requests: 0,
      errors: 0,
      avgResponseTime: 0,
      statusCodes: {},
      endpoints: {}
    };
  }
}

export const metricsCollector = new MetricsCollector();

export const metricsMiddleware = (req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    metricsCollector.recordRequest(req.method, req.path, res.statusCode, duration);
  });

  next();
};

export const healthCheck = async (io) => {
  try {
    const metrics = metricsCollector.getMetrics();
    const uptime = process.uptime();
    const memory = process.memoryUsage();

    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: `${(uptime / 3600).toFixed(2)} hours`,
      metrics,
      memory: {
        heapUsed: `${Math.round(memory.heapUsed / 1024 / 1024)}MB`,
        heapTotal: `${Math.round(memory.heapTotal / 1024 / 1024)}MB`
      },
      socketConnections: io ? io.engine.clientsCount : 0
    };
  } catch (error) {
    logger.error('Health check error', { error: error.message });
    return { status: 'unhealthy', error: error.message };
  }
};

export default {
  logger,
  logMiddleware,
  errorLogger,
  MetricsCollector,
  metricsCollector,
  metricsMiddleware,
  healthCheck
};
