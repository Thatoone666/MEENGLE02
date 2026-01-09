import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import redis from 'redis';

const redisClient = redis.createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379
});

export const loginLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'login:',
  }),
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts, try again later'
});

export const apiLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'api:',
  }),
  windowMs: 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});

export const paymentLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'payment:',
  }),
  windowMs: 60 * 60 * 1000,
  max: 10,
  message: 'Too many payment attempts, try again later'
});

export const strictLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'strict:',
  }),
  windowMs: 60 * 1000,
  max: 10,
  message: 'Too many requests, try again later'
});
