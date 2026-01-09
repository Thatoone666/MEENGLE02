const mongoose = require('mongoose');

const circleSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  description: String,
  type: {
    type: String,
    enum: ['hobby', 'interest', 'lifestyle', 'community', 'other'],
    default: 'community',
  },
  memberCount: {
    type: Number,
    default: 0,
  },
  icon: String,
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const circleMembershipSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  circleId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Circle',
    required: true,
    index: true,
  },
  role: {
    type: String,
    enum: ['member', 'moderator', 'admin'],
    default: 'member',
  },
  joinedAt: {
    type: Date,
    default: Date.now,
  },
});

circleMembershipSchema.index({ userId: 1, circleId: 1 }, { unique: true });

module.exports = {
  Circle: mongoose.model('Circle', circleSchema),
  CircleMembership: mongoose.model('CircleMembership', circleMembershipSchema),
};
