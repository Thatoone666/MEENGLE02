const redis = require('redis');
const logger = require('../config/logger');

class CacheService {
  constructor() {
    this.client = redis.createClient({
      host: process.env.REDIS_HOST || 'localhost',
      port: process.env.REDIS_PORT || 6379,
      password: process.env.REDIS_PASSWORD || undefined,
      db: process.env.REDIS_DB || 0,
    });

    this.client.on('error', (err) => {
      logger.error('Redis client error', { error: err.message });
    });

    this.client.on('connect', () => {
      logger.info('Redis connected');
    });
  }

  /**
   * Connect to Redis
   */
  async connect() {
    try {
      await this.client.connect?.();
      logger.info('Cache service connected');
    } catch (error) {
      logger.error('Failed to connect to cache', { error: error.message });
      throw error;
    }
  }

  /**
   * Get value from cache
   */
  async get(key) {
    try {
      const value = await this.client.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.warn('Cache get error', { key, error: error.message });
      return null;
    }
  }

  /**
   * Set value in cache
   */
  async set(key, value, ttl = 3600) {
    try {
      const serialized = JSON.stringify(value);
      if (ttl) {
        await this.client.setEx(key, ttl, serialized);
      } else {
        await this.client.set(key, serialized);
      }
      return true;
    } catch (error) {
      logger.warn('Cache set error', { key, error: error.message });
      return false;
    }
  }

  /**
   * Delete key from cache
   */
  async delete(key) {
    try {
      await this.client.del(key);
      return true;
    } catch (error) {
      logger.warn('Cache delete error', { key, error: error.message });
      return false;
    }
  }

  /**
   * Clear all cache
   */
  async clear() {
    try {
      await this.client.flushDb();
      logger.info('Cache cleared');
      return true;
    } catch (error) {
      logger.error('Failed to clear cache', { error: error.message });
      return false;
    }
  }

  /**
   * Check if key exists
   */
  async exists(key) {
    try {
      return (await this.client.exists(key)) === 1;
    } catch (error) {
      logger.warn('Cache exists error', { key, error: error.message });
      return false;
    }
  }

  /**
   * Get multiple keys
   */
  async getMany(keys) {
    try {
      const values = await this.client.mGet(keys);
      return values.map(v => (v ? JSON.parse(v) : null));
    } catch (error) {
      logger.warn('Cache getMany error', { error: error.message });
      return keys.map(() => null);
    }
  }

  /**
   * Set multiple keys
   */
  async setMany(pairs, ttl = 3600) {
    try {
      const pipeline = this.client.multi();
      for (const [key, value] of Object.entries(pairs)) {
        const serialized = JSON.stringify(value);
        if (ttl) {
          pipeline.setEx(key, ttl, serialized);
        } else {
          pipeline.set(key, serialized);
        }
      }
      await pipeline.exec();
      return true;
    } catch (error) {
      logger.warn('Cache setMany error', { error: error.message });
      return false;
    }
  }

  /**
   * Increment counter
   */
  async increment(key, amount = 1) {
    try {
      return await this.client.incrBy(key, amount);
    } catch (error) {
      logger.warn('Cache increment error', { key, error: error.message });
      return 0;
    }
  }

  /**
   * Get all keys
   */
  async getKeys(pattern = '*') {
    try {
      return await this.client.keys(pattern);
    } catch (error) {
      logger.warn('Cache getKeys error', { error: error.message });
      return [];
    }
  }

  /**
   * Disconnect from Redis
   */
  async disconnect() {
    try {
      await this.client.quit();
      logger.info('Cache service disconnected');
    } catch (error) {
      logger.error('Failed to disconnect cache', { error: error.message });
    }
  }
}

module.exports = new CacheService();
