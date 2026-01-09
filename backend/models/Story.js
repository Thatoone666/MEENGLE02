const mongoose = require('mongoose');

const storySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  imageUrl: {
    type: String,
    required: true,
  },
  caption: String,
  viewCount: {
    type: Number,
    default: 0,
  },
  reactionCount: {
    type: Number,
    default: 0,
  },
  isViewed: {
    type: Boolean,
    default: false,
  },
  expiresAt: {
    type: Date,
    required: true,
    index: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const storyReactionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  storyId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Story',
    required: true,
    index: true,
  },
  emoji: {
    type: String,
    default: '??',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

storyReactionSchema.index({ storyId: 1, userId: 1 }, { unique: true });

module.exports = {
  Story: mongoose.model('Story', storySchema),
  StoryReaction: mongoose.model('StoryReaction', storyReactionSchema),
};
