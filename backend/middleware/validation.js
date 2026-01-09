import { body, param, query, validationResult } from 'express-validator';

export const validateInput = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

export const validateMessage = [
  body('message')
    .trim()
    .notEmpty().withMessage('Message cannot be empty')
    .isLength({ max: 5000 }).withMessage('Message too long (max 5000 chars)'),
  validateInput
];

export const validateUserId = [
  param('userId').isMongoId().withMessage('Invalid user ID'),
  validateInput
];

export const validateCoordinates = [
  body('latitude').isFloat({ min: -90, max: 90 }).withMessage('Invalid latitude'),
  body('longitude').isFloat({ min: -180, max: 180 }).withMessage('Invalid longitude'),
  validateInput
];

export const validatePagination = [
  query('limit').optional().isInt({ min: 1, max: 200 }).withMessage('Invalid limit'),
  query('skip').optional().isInt({ min: 0 }).withMessage('Invalid skip'),
  validateInput
];

export const validateEmail = [
  body('email').isEmail().normalizeEmail().withMessage('Invalid email'),
  validateInput
];

export const validatePassword = [
  body('password')
    .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
    .matches(/[A-Z]/).withMessage('Password must contain uppercase letter')
    .matches(/[0-9]/).withMessage('Password must contain number'),
  validateInput
];

export const validatePayment = [
  body('amount').isFloat({ min: 0.01 }).withMessage('Invalid amount'),
  body('currency').isLength({ min: 3, max: 3 }).withMessage('Invalid currency'),
  body('method').notEmpty().withMessage('Payment method required'),
  validateInput
];

export const sanitizeMessage = (req, res, next) => {
  if (req.body.message) {
    req.body.message = req.body.message
      .trim()
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }
  next();
};

export const rateLimitByUser = (maxRequests = 100, windowMs = 60000) => {
  const store = new Map();

  return (req, res, next) => {
    const userId = req.userId || req.ip;
    const now = Date.now();
    const userRequests = store.get(userId) || [];
    
    const recentRequests = userRequests.filter(time => now - time < windowMs);
    
    if (recentRequests.length >= maxRequests) {
      return res.status(429).json({ error: 'Too many requests' });
    }

    recentRequests.push(now);
    store.set(userId, recentRequests);
    next();
  };
};
