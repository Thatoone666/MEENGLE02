const mongoose = require('mongoose');

const fraudPatternSchema = new mongoose.Schema({
  pattern: {
    type: String,
    required: true,
    unique: true,
  },
  description: {
    type: String,
    required: true,
  },
  riskLevel: {
    type: String,
    enum: ['low', 'medium', 'high'],
    required: true,
  },
  indicators: [{
    type: String,
  }],
  isActive: {
    type: Boolean,
    default: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  }
});

fraudPatternSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('FraudPattern', fraudPatternSchema);