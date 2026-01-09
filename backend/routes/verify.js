import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const verificationSchema = new mongoose.Schema({
  userId: String,
  type: String,
  status: { type: String, default: 'pending' },
  verifiedAt: Date,
  expiresAt: Date,
  createdAt: { type: Date, default: Date.now }
});

let Verification;
try {
  Verification = mongoose.model('UserVerification', verificationSchema);
} catch {
  Verification = mongoose.model('UserVerification');
}

// Get verification status
router.get('/status', verifyToken, async (req, res) => {
  try {
    const verification = await Verification.findOne({ userId: req.userId });
    res.json(verification || { status: 'unverified' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch verification' });
  }
});

// Start verification
router.post('/start', verifyToken, async (req, res) => {
  try {
    const { type } = req.body;
    const verification = new Verification({
      userId: req.userId,
      type,
      status: 'pending',
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000)
    });
    await verification.save();
    res.json({ success: true, verification });
  } catch (error) {
    res.status(500).json({ error: 'Failed to start verification' });
  }
});

// Verify user
router.post('/verify', verifyToken, async (req, res) => {
  try {
    const verification = await Verification.findOneAndUpdate(
      { userId: req.userId },
      { status: 'verified', verifiedAt: new Date() },
      { new: true }
    );
    res.json({ success: true, verification });
  } catch (error) {
    res.status(500).json({ error: 'Verification failed' });
  }
});

export default router;
