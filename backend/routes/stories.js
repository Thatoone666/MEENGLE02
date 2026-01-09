import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const storySchema = new mongoose.Schema({
  userId: String,
  photo: String,
  caption: String,
  expiresAt: Date,
  views: [String],
  createdAt: { type: Date, default: Date.now }
});

let Story;
try {
  Story = mongoose.model('Story', storySchema);
} catch {
  Story = mongoose.model('Story');
}

router.get('/feed', verifyToken, async (req, res) => {
  try {
    const stories = await Story.find({
      expiresAt: { $gt: new Date() }
    }).limit(50);
    res.json(stories);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch stories' });
  }
});

router.post('/create', verifyToken, async (req, res) => {
  try {
    const { photo, caption } = req.body;
    const story = new Story({
      userId: req.userId,
      photo,
      caption,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      views: []
    });
    await story.save();
    res.json({ success: true, story });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create story' });
  }
});

export default router;
