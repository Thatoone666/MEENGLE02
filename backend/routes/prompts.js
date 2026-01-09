import express from 'express';
import { body, validationResult } from 'express-validator';
import mongoose from 'mongoose';

// Middleware for verifying token
import { verifyToken } from './auth.js';

const router = express.Router();

// Prompt schema for MongoDB
const promptSchema = new mongoose.Schema({
  userId: String,
  promptId: String,
  answer: String,
  isVerified: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

let Prompt;
try {
  Prompt = mongoose.model('Prompt', promptSchema);
} catch {
  Prompt = mongoose.model('Prompt');
}

// GET /api/prompts/discover - Get unanswered prompts for current user
router.get('/discover', verifyToken, async (req, res) => {
  try {
    const answered = await Prompt.find({ userId: req.userId }).select('promptId');
    const answeredIds = answered.map((p) => p.promptId);

    // Sample prompts - in real app, fetch from another service or database
    const allPrompts = [
      {
        id: 'travel_1',
        question: 'Where do you most want to travel next?',
        category: 'travelDreams',
        suggestedAnswers: ['Southeast Asia', 'Europe', 'South America', 'Africa'],
        characterLimit: 250,
      },
      {
        id: 'hobby_1',
        question: 'What\'s your favorite hobby?',
        category: 'hobbies',
        suggestedAnswers: ['Reading', 'Traveling', 'Gardening', 'Cooking'],
        characterLimit: 150,
      },
      // Add more prompts as needed
    ];

    const unanswered = allPrompts.filter((p) => !answeredIds.includes(p.id));
    res.json({
      success: true,
      prompts: unanswered,
      answeredCount: answeredIds.length,
      totalCount: allPrompts.length,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/prompts/answers - Submit a prompt answer
router.post(
  '/answers',
  verifyToken,
  [
    body('promptId').notEmpty().withMessage('promptId is required'),
    body('answer').notEmpty().withMessage('answer is required'),
    body('answer')
      .isLength({ max: 250 })
      .withMessage('answer must be 250 characters or less'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    try {
      const { promptId, answer, isVerified } = req.body;

      // Check if already answered
      let existing = await Prompt.findOne({
        userId: req.userId,
        promptId: promptId,
      });

      if (existing) {
        // Update existing answer
        existing.answer = answer;
        existing.isVerified = isVerified || false;
        existing.updatedAt = new Date();
        await existing.save();
      } else {
        // Create new answer
        existing = new Prompt({
          userId: req.userId,
          promptId,
          answer,
          isVerified: isVerified || false,
        });
        await existing.save();
      }

      res.json({ success: true, answer: existing });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }
);

// GET /api/prompts/:userId - Get user's answered prompts
router.get('/:userId', async (req, res) => {
  try {
    const answers = await Prompt.find({ userId: req.params.userId });
    res.json({ success: true, answers, count: answers.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/prompts/answers/:answerId - Edit prompt answer
router.put(
  '/answers/:answerId',
  verifyToken,
  [body('answer').notEmpty().withMessage('answer is required')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    try {
      const answerId = req.params.answerId;
      const { answer } = req.body;

      const existing = await Prompt.findById(answerId);

      if (!existing) {
        return res.status(404).json({
          success: false,
          error: 'Answer not found',
        });
      }

      if (existing.userId !== req.userId) {
        return res.status(403).json({
          success: false,
          error: 'Not authorized to edit this answer',
        });
      }

      existing.answer = answer;
      existing.updatedAt = new Date();
      await existing.save();

      res.json({ success: true, answer: existing });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  }
);

// DELETE /api/prompts/answers/:answerId - Delete prompt answer
router.delete('/answers/:answerId', verifyToken, async (req, res) => {
  try {
    const answerId = req.params.answerId;
    const existing = await Prompt.findById(answerId);

    if (!existing) {
      return res.status(404).json({
        success: false,
        error: 'Answer not found',
      });
    }

    if (existing.userId !== req.userId) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to delete this answer',
      });
    }

    await Prompt.deleteOne({ _id: answerId });

    res.json({ success: true, message: 'Answer deleted' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
