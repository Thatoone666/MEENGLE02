const logger = require('../config/logger');
const Sentry = require('@sentry/node');

const errorHandler = (err, req, res, next) => {
    const status = err.status || 500;
    const message = err.message || 'Internal Server Error';

    // Log the error
    logger.error(`${status} - ${message} - ${req.originalUrl} - ${req.method} - ${req.ip}`, {
        stack: err.stack
    });

    // Don't send stack trace in production
    const payload = { message };
    if (process.env.NODE_ENV !== 'production') {
        payload.stack = err.stack;
    }

    res.status(status).json(payload);
};

const sentryErrorHandler = () => {
    if (process.env.SENTRY_DSN) {
        return Sentry.Handlers.errorHandler();
    }
    // Return a no-op middleware if Sentry is not configured
    return (err, req, res, next) => next(err);
};

module.exports = {
    errorHandler,
    sentryErrorHandler
};
