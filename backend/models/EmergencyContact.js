const mongoose = require('mongoose');

const emergencyContactSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true,
  },
  name: {
    type: String,
    required: true,
  },
  phoneNumber: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
  },
  isFavourite: {
    type: Boolean,
    default: false,
  },
  addedAt: {
    type: Date,
    default: Date.now,
  },
  lastNotified: {
    type: Date,
  },
  totalShares: {
    type: Number,
    default: 0,
  },
});

// Index for quick lookups
emergencyContactSchema.index({ userId: 1, isFavourite: 1 });

module.exports = mongoose.model('EmergencyContact', emergencyContactSchema);
