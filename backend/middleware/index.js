const cors = require('cors');
const express = require('express');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
const Sentry = require('@sentry/node');
const path = require('path');
const logger = require('../config/logger');
const metrics = require('../lib/metrics');

let clientMetrics = metrics.client;
let httpRequestCounter = { inc: () => {} };
try {
    if (clientMetrics) {
        httpRequestCounter = new clientMetrics.Counter({ name: 'http_requests_total', help: 'Total HTTP requests', labelNames: ['method','route','status'] });
    }
} catch (e) { httpRequestCounter = { inc: () => {} }; }


const configureMiddleware = (app) => {
    // Restrictive CORS
    const allowedOrigins = (process.env.CORS_ORIGINS || 'http://localhost:3000,http://127.0.0.1:3000').split(',').map(s => s.trim());
    app.use(cors({
        origin: function(origin, callback) {
            if (!origin || allowedOrigins.indexOf(origin) !== -1) {
                callback(null, true);
            } else {
                callback(new Error('Not allowed by CORS'));
            }
        }
    }));

    // Body parser
    app.use(bodyParser.json({ limit: '100kb' }));

    // Serve static files for uploads
    app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

    // Security headers
    app.use(helmet());
    app.use(helmet.contentSecurityPolicy({
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'", "'unsafe-inline'"], // Consider removing unsafe-inline
            styleSrc: ["'self'", "'unsafe-inline'"], // Consider removing unsafe-inline
            imgSrc: ["'self'", 'data:'],
            connectSrc: ["'self'", 'ws:', 'wss:'],
            objectSrc: ["'none'"],
            upgradeInsecureRequests: []
        }
    }));

    // Rate limiting
    const limiter = rateLimit({
        windowMs: 15 * 60 * 1000, // 15 minutes
        max: 100, // limit each IP to 100 requests per windowMs
        standardHeaders: true,
        legacyHeaders: false,
    });
    app.use(limiter);

    // Sentry request handler (must be first middleware)
    if (process.env.SENTRY_DSN) {
        app.use(Sentry.Handlers.requestHandler());
        app.use(Sentry.Handlers.tracingHandler());
    }

    // Morgan HTTP request logging
    app.use(morgan('combined', {
        stream: {
            write: (message) => logger.info(message.trim())
        }
    }));

    // Basic metrics middleware
    app.use((req, res, next) => {
        res.on('finish', () => {
            if (req.route) { // Ensure route is matched before logging metric
                httpRequestCounter.inc({ method: req.method, route: req.route.path, status: res.statusCode });
            }
        });
        next();
    });
};

module.exports = configureMiddleware;
