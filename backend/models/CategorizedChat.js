const mongoose = require('mongoose');

const categorizedChatSchema = new mongoose.Schema({
  chatId: {
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
    ref: 'ChatCategory',
    required: true,
    index: true,
  },
  isPinned: {
    type: Boolean,
    default: false,
    index: true,
  },
  categorizedAt: {
    type: Date,
    default: Date.now,
    index: true,
  },
});

// Compound index for quick lookups
categorizedChatSchema.index({ userId: 1, categoryId: 1, isPinned: -1 });

module.exports = mongoose.model('CategorizedChat', categorizedChatSchema);
