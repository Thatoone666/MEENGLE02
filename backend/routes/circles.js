import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const circleSchema = new mongoose.Schema({
  name: String,
  description: String,
  members: [String],
  createdBy: String,
  createdAt: { type: Date, default: Date.now }
});

let Circle;
try {
  Circle = mongoose.model('Circle', circleSchema);
} catch {
  Circle = mongoose.model('Circle');
}

router.get('/discover', verifyToken, async (req, res) => {
  try {
    const circles = await Circle.find().limit(20);
    res.json(circles);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch circles' });
  }
});

router.post('/create', verifyToken, async (req, res) => {
  try {
    const { name, description } = req.body;
    const circle = new Circle({
      name,
      description,
      createdBy: req.userId,
      members: [req.userId]
    });
    await circle.save();
    res.json({ success: true, circle });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create circle' });
  }
});

export default router;
