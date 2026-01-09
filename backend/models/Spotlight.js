const mongoose = require('mongoose');

const spotlightSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  tier: {
    type: String,
    enum: ['silver', 'gold', 'platinum'],
    required: true,
  },
  status: {
    type: String,
    enum: ['active', 'expired'],
    default: 'active',
  },
  expiresAt: {
    type: Date,
    required: true,
    index: true,
  },
  viewCount: {
    type: Number,
    default: 0,
  },
  engagementScore: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const spotlightPurchaseSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  tier: {
    type: String,
    required: true,
  },
  price: Number,
  transactionId: String,
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = {
  Spotlight: mongoose.model('Spotlight', spotlightSchema),
  SpotlightPurchase: mongoose.model('SpotlightPurchase', spotlightPurchaseSchema),
};
