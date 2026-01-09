import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const dateSchema = new mongoose.Schema({
  userId: String,
  partnerId: String,
  idea: String,
  date: Date,
  location: String,
  status: { type: String, default: 'proposed' },
  createdAt: { type: Date, default: Date.now }
});

let DateBooking;
try {
  DateBooking = mongoose.model('DateBooking', dateSchema);
} catch {
  DateBooking = mongoose.model('DateBooking');
}

router.get('/ideas', async (req, res) => {
  try {
    const ideas = [
      { id: 1, idea: 'Coffee at local cafe', rating: 4.5 },
      { id: 2, idea: 'Dinner and movie', rating: 4.8 }
    ];
    res.json(ideas);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch ideas' });
  }
});

router.post('/propose', verifyToken, async (req, res) => {
  try {
    const { partnerId, idea, date, location } = req.body;
    const booking = new DateBooking({
      userId: req.userId,
      partnerId,
      idea,
      date,
      location
    });
    await booking.save();
    res.json({ success: true, booking });
  } catch (error) {
    res.status(500).json({ error: 'Failed to propose date' });
  }
});

export default router;
