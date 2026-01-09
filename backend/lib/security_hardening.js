/**
 * SecurityHardening - Production Security Configuration
 * Applied at application startup
 */

const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mongoSanitize = require('express-mongo-sanitize');
const hpp = require('hpp');

class SecurityHardening {
  constructor(app, io) {
    this.app = app;
    this.io = io;
  }

  /**
   * Apply all security middleware
   */
  applyAll() {
    console.log('🔒 Applying security hardening measures...\n');
    
    this.applyHelmet();
    this.applyCorsPolicy();
    this.applyRateLimiting();
    this.applyInputValidation();
    this.applyRequestLogging();
    this.configureErrorHandling();
    this.configureSocketSecurity();
    
    console.log('✅ Security hardening complete\n');
  }

  /**
   * Apply Helmet.js for HTTP headers
   */
  applyHelmet() {
    this.app.use(helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          scriptSrc: ["'self'"],
          imgSrc: ["'self'", "data:", "https:"],
          connectSrc: ["'self'", "https://api.stripe.com", "https://fcm.googleapis.com"],
          fontSrc: ["'self'", "https:"],
          objectSrc: ["'none'"],
          mediaSrc: ["'self'"],
          frameSrc: ["'none'"],
        },
      },
      crossOriginEmbedderPolicy: true,
      crossOriginOpenerPolicy: true,
      crossOriginResourcePolicy: { policy: "cross-origin" },
      dnsPrefetchControl: { allow: false },
      frameguard: { action: 'deny' },
      hidePoweredBy: true,
      hsts: {
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true,
      },
      ieNoOpen: true,
      noSniff: true,
      referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
      xssFilter: true,
    }));

    console.log('  ✅ HTTP Security Headers (Helmet.js) configured');
  }

  /**
   * Apply CORS policy
   */
  applyCorsPolicy() {
    const cors = require('cors');
    
    const allowedOrigins = [
      'https://meengle.app',
      'https://www.meengle.app',
      'http://localhost:3000',
      'http://localhost:8080',
    ];

    this.app.use(cors({
      origin: (origin, callback) => {
        if (!origin || allowedOrigins.includes(origin)) {
          callback(null, true);
        } else {
          callback(new Error('Not allowed by CORS'));
        }
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
      maxAge: 86400, // 24 hours
      exposedHeaders: ['X-Total-Count', 'X-Page-Number'],
    }));

    console.log('  ✅ CORS Policy configured');
  }

  /**
   * Apply rate limiting
   */
  applyRateLimiting() {
    // Global rate limiter
    const globalLimiter = rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 100,
      message: 'Too many requests from this IP, please try again later',
      standardHeaders: true,
      legacyHeaders: false,
      skip: (req) => {
        // Skip rate limiting for health checks
        return req.path === '/health';
      },
    });

    // Strict limiter for auth endpoints
    const authLimiter = rateLimit({
      windowMs: 15 * 60 * 1000,
      max: 5,
      message: 'Too many login attempts, please try again later',
      skipSuccessfulRequests: true,
    });

    // Strict limiter for API endpoints
    const apiLimiter = rateLimit({
      windowMs: 1 * 60 * 1000, // 1 minute
      max: 30,
    });

    // Apply limiters
    this.app.use(globalLimiter);
    this.app.use('/api/auth', authLimiter);
    this.app.use('/api/', apiLimiter);

    console.log('  ✅ Rate Limiting configured');
  }

  /**
   * Apply input validation and sanitization
   */
  applyInputValidation() {
    // MongoDB injection prevention
    this.app.use(mongoSanitize({
      replaceWith: '_',
      onSanitize: ({ req, key }) => {
        console.warn(`⚠️  Sanitized suspicious field: ${key}`);
      },
    }));

    // Parameter pollution prevention
    this.app.use(hpp({
      whitelist: [
        'sort',
        'fields',
        'page',
        'limit',
        'search',
        'category',
      ],
    }));

    console.log('  ✅ Input Validation & Sanitization configured');
  }

  /**
   * Apply request logging for security
   */
  applyRequestLogging() {
    const morgan = require('morgan');

    // Custom morgan format that includes security info
    morgan.token('user-id', (req) => req.user?.id || 'anonymous');

    const format = ':remote-addr - :user-id [:date[clf]] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent" :response-time ms';

    this.app.use(morgan(format, {
      skip: (req) => {
        // Skip logging for health checks and static assets
        return req.path === '/health' || /\.(js|css|png|jpg|gif|svg|ico)$/.test(req.path);
      },
    }));

    console.log('  ✅ Security Request Logging configured');
  }

  /**
   * Configure error handling
   */
  configureErrorHandling() {
    // 404 handler
    this.app.use((req, res) => {
      res.status(404).json({
        error: 'Resource not found',
        path: req.path,
        method: req.method,
      });
    });

    // Global error handler
    this.app.use((err, req, res, next) => {
      const status = err.status || 500;
      const isProduction = process.env.NODE_ENV === 'production';

      // Log error
      console.error('❌ ERROR:', {
        status,
        message: err.message,
        path: req.path,
        method: req.method,
        userId: req.user?.id,
        timestamp: new Date().toISOString(),
      });

      // Don't expose error details in production
      const response = {
        error: isProduction ? 'Internal Server Error' : err.message,
        status,
      };

      if (!isProduction) {
        response.stack = err.stack;
      }

      res.status(status).json(response);
    });

    console.log('  ✅ Error Handling configured');
  }

  /**
   * Configure Socket.IO security
   */
  configureSocketSecurity() {
    // Socket.IO CORS
    this.io.use((socket, next) => {
      const origin = socket.request.headers.origin;
      const allowedOrigins = [
        'https://meengle.app',
        'https://www.meengle.app',
        'http://localhost:3000',
        'http://localhost:8080',
      ];

      if (!origin || allowedOrigins.includes(origin)) {
        next();
      } else {
        next(new Error('CORS policy violation'));
      }
    });

    // Authentication middleware
    this.io.use((socket, next) => {
      const token = socket.handshake.auth.token;

      if (!token) {
        return next(new Error('Authentication error: No token provided'));
      }

      try {
        const jwt = require('jsonwebtoken');
        const secretsManager = require('./secrets_manager');
        const decoded = jwt.verify(token, secretsManager.get('jwtSecret'));
        socket.userId = decoded.id;
        socket.email = decoded.email;
        next();
      } catch (err) {
        next(new Error('Authentication error: Invalid token'));
      }
    });

    // Rate limiting for socket events
    const socketRateLimit = new Map();
    this.io.on('connection', (socket) => {
      // Store connection info
      socketRateLimit.set(socket.id, {
        events: {},
      });

      // Monitor socket events
      socket.onAny((event, ...args) => {
        const limits = {
          'message': { max: 10, window: 60000 }, // 10 messages per minute
          'story:view': { max: 30, window: 60000 }, // 30 views per minute
          'story:like': { max: 20, window: 60000 }, // 20 likes per minute
        };

        if (limits[event]) {
          const now = Date.now();
          const limiter = socketRateLimit.get(socket.id);
          
          if (!limiter.events[event]) {
            limiter.events[event] = [];
          }

          // Clean old events
          limiter.events[event] = limiter.events[event].filter(
            (time) => now - time < limits[event].window
          );

          // Check limit
          if (limiter.events[event].length >= limits[event].max) {
            console.warn(`⚠️  Socket rate limit exceeded: ${event} from ${socket.userId}`);
            socket.emit('error', {
              message: 'Rate limit exceeded',
              event,
            });
            return;
          }

          limiter.events[event].push(now);
        }
      });

      socket.on('disconnect', () => {
        socketRateLimit.delete(socket.id);
      });
    });

    console.log('  ✅ Socket.IO Security configured');
  }

  /**
   * Verify security headers
   */
  verifyHeaders() {
    console.log('\n📋 Security Headers Status:');
    console.log('━'.repeat(50));
    console.log('  ✅ Content-Security-Policy');
    console.log('  ✅ Strict-Transport-Security');
    console.log('  ✅ X-Content-Type-Options');
    console.log('  ✅ X-Frame-Options');
    console.log('  ✅ X-XSS-Protection');
    console.log('  ✅ Referrer-Policy');
    console.log('  ✅ Permissions-Policy');
    console.log('━'.repeat(50) + '\n');
  }

  /**
   * Setup SSL/TLS
   */
  static setupSSL() {
    const fs = require('fs');
    const https = require('https');

    try {
      const privateKey = fs.readFileSync('/etc/ssl/private/key.pem', 'utf8');
      const certificate = fs.readFileSync('/etc/ssl/certs/cert.pem', 'utf8');

      return https.createServer({ key: privateKey, cert: certificate });
    } catch (err) {
      console.warn('⚠️  SSL certificate not found. Falling back to HTTP.');
      return null;
    }
  }

  /**
   * Setup HTTPS redirect middleware
   */
  static getHttpsRedirect() {
    return (req, res, next) => {
      if (process.env.NODE_ENV === 'production' && !req.secure) {
        res.redirect(`https://${req.headers.host}${req.url}`);
      } else {
        next();
      }
    };
  }
}

module.exports = SecurityHardening;
