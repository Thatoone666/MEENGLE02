import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const spotlightSchema = new mongoose.Schema({
  userId: String,
  type: String,
  duration: Number,
  expiresAt: Date,
  createdAt: { type: Date, default: Date.now }
});

let Spotlight;
try {
  Spotlight = mongoose.model('Spotlight', spotlightSchema);
} catch {
  Spotlight = mongoose.model('Spotlight');
}

router.get('/active', async (req, res) => {
  try {
    const spotlight = await Spotlight.find({
      expiresAt: { $gt: new Date() }
    }).limit(10);
    res.json(spotlight);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch spotlight' });
  }
});

router.post('/activate', verifyToken, async (req, res) => {
  try {
    const { type, duration } = req.body;
    const spotlight = new Spotlight({
      userId: req.userId,
      type,
      duration,
      expiresAt: new Date(Date.now() + duration * 60 * 60 * 1000)
    });
    await spotlight.save();
    res.json({ success: true, spotlight });
  } catch (error) {
    res.status(500).json({ error: 'Failed to activate spotlight' });
  }
});

export default router;
