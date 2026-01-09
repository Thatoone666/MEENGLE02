const mongoose = require('mongoose');

const chatCategorySchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true,
  },
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  color: {
    type: String,
    default: '#FF6B9A',
  },
  messageCount: {
    type: Number,
    default: 0,
  },
  isDefault: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
    index: true,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Index for quick lookups
chatCategorySchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('ChatCategory', chatCategorySchema);
