import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const ontheflySchema = new mongoose.Schema({
  userId: String,
  targetLocation: { latitude: Number, longitude: Number },
  status: { type: String, default: 'active' },
  createdAt: { type: Date, default: Date.now }
});

let OnTheFly;
try {
  OnTheFly = mongoose.model('OnTheFly', ontheflySchema);
} catch {
  OnTheFly = mongoose.model('OnTheFly');
}

router.get('/nearby', verifyToken, async (req, res) => {
  try {
    const { latitude, longitude } = req.query;
    const users = await OnTheFly.find().limit(20);
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch nearby users' });
  }
});

router.post('/location', verifyToken, async (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    const user = await OnTheFly.findOneAndUpdate(
      { userId: req.userId },
      { targetLocation: { latitude, longitude } },
      { upsert: true, new: true }
    );
    res.json({ success: true, user });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update location' });
  }
});

export default router;
