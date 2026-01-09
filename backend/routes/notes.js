import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const noteSchema = new mongoose.Schema({
  userId: String,
  otherUserId: String,
  note: String,
  isPublic: Boolean,
  createdAt: { type: Date, default: Date.now }
});

let Note;
try {
  Note = mongoose.model('Note', noteSchema);
} catch {
  Note = mongoose.model('Note');
}

router.post('/add', verifyToken, async (req, res) => {
  try {
    const { otherUserId, note, isPublic } = req.body;
    const newNote = new Note({
      userId: req.userId,
      otherUserId,
      note,
      isPublic
    });
    await newNote.save();
    res.json({ success: true, note: newNote });
  } catch (error) {
    res.status(500).json({ error: 'Failed to add note' });
  }
});

router.get('/:otherUserId', verifyToken, async (req, res) => {
  try {
    const note = await Note.findOne({
      userId: req.userId,
      otherUserId: req.params.otherUserId
    });
    res.json(note || { note: '' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch note' });
  }
});

export default router;
