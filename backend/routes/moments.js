import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const momentSchema = new mongoose.Schema({
  userId: String,
  photo: String,
  caption: String,
  expiresAt: Date,
  createdAt: { type: Date, default: Date.now }
});

let Moment;
try {
  Moment = mongoose.model('Moment', momentSchema);
} catch {
  Moment = mongoose.model('Moment');
}

router.get('/feed', verifyToken, async (req, res) => {
  try {
    const moments = await Moment.find({
      expiresAt: { $gt: new Date() }
    }).limit(20);
    res.json(moments);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch moments' });
  }
});

router.post('/create', verifyToken, async (req, res) => {
  try {
    const { photo, caption } = req.body;
    const moment = new Moment({
      userId: req.userId,
      photo,
      caption,
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000)
    });
    await moment.save();
    res.json({ success: true, moment });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create moment' });
  }
});

export default router;
