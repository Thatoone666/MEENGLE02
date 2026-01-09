import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const boostSchema = new mongoose.Schema({
  userId: String,
  type: String,
  duration: Number,
  expiresAt: Date,
  createdAt: { type: Date, default: Date.now },
});

let Boost;
try {
  Boost = mongoose.model('Boost', boostSchema);
} catch {
  Boost = mongoose.model('Boost');
}

// Get active boosts
router.get('/active', verifyToken, async (req, res) => {
  try {
    const boosts = await Boost.find({
      userId: req.userId,
      expiresAt: { $gt: new Date() },
    });
    res.json(boosts);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch boosts' });
  }
});

// Create boost
router.post('/create', verifyToken, async (req, res) => {
  try {
    const { type, duration } = req.body;
    const boost = new Boost({
      userId: req.userId,
      type,
      duration,
      expiresAt: new Date(Date.now() + duration * 60 * 60 * 1000),
    });
    await boost.save();
    res.json({ success: true, boost });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create boost' });
  }
});

export default router;
