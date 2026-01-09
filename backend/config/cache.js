module.exports = {
  // Redis cache configuration
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
    password: process.env.REDIS_PASSWORD,
    db: process.env.REDIS_DB || 0,
    retryStrategy: function (options) {
      if (options.error && options.error.code === 'ECONNREFUSED') {
        return new Error('End of retry.');
      }
      if (options.total_retry_time > 1000 * 60 * 60) {
        return new Error('Retry time exhausted');
      }
      if (options.attempt > 10) {
        return undefined;
      }
      return Math.min(options.attempt * 100, 3000);
    },
  },

  // Cache TTL (Time To Live) in seconds
  ttl: {
    short: 300, // 5 minutes
    medium: 3600, // 1 hour
    long: 86400, // 24 hours
    user: 3600, // 1 hour for user data
    session: 86400, // 24 hours for session data
  },

  // Cache keys prefix
  keyPrefix: 'meengle:',

  // Cache strategies
  strategies: {
    user: {
      ttl: 3600,
      prefix: 'user:',
    },
    session: {
      ttl: 86400,
      prefix: 'session:',
    },
    match: {
      ttl: 3600,
      prefix: 'match:',
    },
    search: {
      ttl: 600,
      prefix: 'search:',
    },
    notification: {
      ttl: 3600,
      prefix: 'notification:',
    },
  },

  // Cache warming (preload frequently used data)
  warming: {
    enabled: process.env.CACHE_WARMING === 'true',
    interval: 3600000, // 1 hour
  },

  // Cache invalidation rules
  invalidation: {
    onUserUpdate: ['user:', 'match:', 'search:'],
    onMatch: ['match:', 'notification:'],
    onMessage: ['notification:'],
  },
};
