const mongoose = require('mongoose');

const momentSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  matchId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  matchName: String,
  status: {
    type: String,
    enum: ['active', 'accepted', 'rejected', 'expired'],
    default: 'active',
  },
  expiresAt: {
    type: Date,
    required: true,
    index: true,
  },
  extensionsUsed: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Moment', momentSchema);
