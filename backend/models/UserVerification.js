const mongoose = require('mongoose');

const userVerificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  verificationType: {
    type: String,
    enum: ['phone', 'email', 'id', 'photo', 'background', 'video', 'payment'],
    required: true,
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'expired'],
    default: 'pending',
  },
  proofUrl: String,
  reviewedAt: Date,
  expiresAt: Date,
  createdAt: {
    type: Date,
    default: Date.now,
    index: true,
  },
});

userVerificationSchema.index({ userId: 1, verificationType: 1 }, { unique: true });

module.exports = mongoose.model('UserVerification', userVerificationSchema);
