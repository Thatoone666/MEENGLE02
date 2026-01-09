const mongoose = require('mongoose');

const categorizedMatchSchema = new mongoose.Schema({
  matchId: {
    type: String,
    required: true,
    index: true,
  },
  userId: {
    type: String,
    required: true,
    index: true,
  },
  otherUserId: {
    type: String,
    required: true,
  },
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MatchCategory',
    required: true,
    index: true,
  },
  isPinned: {
    type: Boolean,
    default: false,
    index: true,
  },
  notes: {
    type: String,
  },
  categorizedAt: {
    type: Date,
    default: Date.now,
    index: true,
  },
});

// Compound index for quick lookups
categorizedMatchSchema.index({ userId: 1, categoryId: 1, isPinned: -1 });

module.exports = mongoose.model('CategorizedMatch', categorizedMatchSchema);
