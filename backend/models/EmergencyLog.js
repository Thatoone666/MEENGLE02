const mongoose = require('mongoose');

const emergencyLogSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true,
  },
  contactId: {
    type: String,
    required: true,
  },
  location: {
    latitude: {
      type: Number,
      required: true,
    },
    longitude: {
      type: Number,
      required: true,
    },
    accuracy: {
      type: Number,
    },
    address: {
      type: String,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
  },
  serviceType: {
    type: String,
    enum: ['favourite', 'police', 'hospital', 'emergency'],
    default: 'favourite',
  },
  sharedAt: {
    type: Date,
    default: Date.now,
    index: true,
  },
  acknowledged: {
    type: Boolean,
    default: false,
  },
  acknowledgedAt: {
    type: Date,
  },
  notes: {
    type: String,
  },
  ipAddress: {
    type: String,
  },
  userAgent: {
    type: String,
  },
});

// Index for quick lookups
emergencyLogSchema.index({ userId: 1, sharedAt: -1 });
emergencyLogSchema.index({ contactId: 1, sharedAt: -1 });

// TTL index: Delete logs after 90 days for privacy
emergencyLogSchema.index({ sharedAt: 1 }, { expireAfterSeconds: 7776000 });

module.exports = mongoose.model('EmergencyLog', emergencyLogSchema);
