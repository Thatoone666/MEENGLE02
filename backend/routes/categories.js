import express from 'express';
import { authenticateToken } from '../middleware/auth.js';
import ChatCategory from '../models/ChatCategory.js';
import MatchCategory from '../models/MatchCategory.js';
import CategorizedChat from '../models/CategorizedChat.js';
import CategorizedMatch from '../models/CategorizedMatch.js';

const router = express.Router();

/// ==================== CHAT CATEGORY ROUTES ====================

/// @route   GET /api/categories/chat/:userId
/// @desc    Get all chat categories for user
/// @access  Private
router.get('/chat/:userId', authenticateToken, async (req, res) => {
  try {
    const categories = await ChatCategory.find({
      userId: req.params.userId,
    }).sort({ createdAt: -1 });

    res.json({
      success: true,
      categories,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error fetching chat categories',
      error: err.message,
    });
  }
});

/// @route   POST /api/categories/chat
/// @desc    Create new chat category
/// @access  Private
router.post('/chat', authenticateToken, async (req, res) => {
  try {
    const { userId, name, description, color } = req.body;

    const category = new ChatCategory({
      userId,
      name,
      description,
      color,
      messageCount: 0,
      isDefault: false,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await category.save();

    res.status(201).json({
      success: true,
      category,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error creating chat category',
      error: err.message,
    });
  }
});

/// @route   PUT /api/categories/chat/:categoryId
/// @desc    Update chat category
/// @access  Private
router.put('/chat/:categoryId', authenticateToken, async (req, res) => {
  try {
    const { name, description, color } = req.body;

    const category = await ChatCategory.findByIdAndUpdate(
      req.params.categoryId,
      {
        name,
        description,
        color,
        updatedAt: new Date(),
      },
      { new: true }
    );

    res.json({
      success: true,
      category,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error updating chat category',
      error: err.message,
    });
  }
});

/// @route   DELETE /api/categories/chat/:categoryId
/// @desc    Delete chat category
/// @access  Private
router.delete('/chat/:categoryId', authenticateToken, async (req, res) => {
  try {
    // Delete category
    await ChatCategory.findByIdAndDelete(req.params.categoryId);

    // Delete all categorized chats in this category
    await CategorizedChat.deleteMany({ categoryId: req.params.categoryId });

    res.json({
      success: true,
      message: 'Chat category deleted',
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error deleting chat category',
      error: err.message,
    });
  }
});

/// @route   POST /api/categories/chat/assign
/// @desc    Assign chat to category
/// @access  Private
router.post('/chat/assign', authenticateToken, async (req, res) => {
  try {
    const { chatId, userId, otherUserId, categoryId, isPinned } = req.body;

    // Check if already categorized
    let categorized = await CategorizedChat.findOne({ chatId, categoryId });

    if (!categorized) {
      categorized = new CategorizedChat({
        chatId,
        userId,
        otherUserId,
        categoryId,
        isPinned,
        categorizedAt: new Date(),
      });
      await categorized.save();

      // Increment message count in category
      await ChatCategory.findByIdAndUpdate(
        categoryId,
        { $inc: { messageCount: 1 } }
      );
    }

    res.status(201).json({
      success: true,
      categorized,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error assigning chat to category',
      error: err.message,
    });
  }
});

/// @route   GET /api/categories/chat/:categoryId/chats
/// @desc    Get all chats in category
/// @access  Private
router.get('/chat/:categoryId/chats', authenticateToken, async (req, res) => {
  try {
    const chats = await CategorizedChat.find({
      categoryId: req.params.categoryId,
    }).sort({ isPinned: -1, categorizedAt: -1 });

    res.json({
      success: true,
      chats,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error fetching chats',
      error: err.message,
    });
  }
});

/// ==================== MATCH CATEGORY ROUTES ====================

/// @route   GET /api/categories/match/:userId
/// @desc    Get all match categories for user
/// @access  Private
router.get('/match/:userId', authenticateToken, async (req, res) => {
  try {
    const categories = await MatchCategory.find({
      userId: req.params.userId,
    }).sort({ createdAt: -1 });

    res.json({
      success: true,
      categories,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error fetching match categories',
      error: err.message,
    });
  }
});

/// @route   POST /api/categories/match
/// @desc    Create new match category
/// @access  Private
router.post('/match', authenticateToken, async (req, res) => {
  try {
    const { userId, name, description, color, icon } = req.body;

    const category = new MatchCategory({
      userId,
      name,
      description,
      color,
      icon,
      matchCount: 0,
      isDefault: false,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await category.save();

    res.status(201).json({
      success: true,
      category,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error creating match category',
      error: err.message,
    });
  }
});

/// @route   PUT /api/categories/match/:categoryId
/// @desc    Update match category
/// @access  Private
router.put('/match/:categoryId', authenticateToken, async (req, res) => {
  try {
    const { name, description, color, icon } = req.body;

    const category = await MatchCategory.findByIdAndUpdate(
      req.params.categoryId,
      {
        name,
        description,
        color,
        icon,
        updatedAt: new Date(),
      },
      { new: true }
    );

    res.json({
      success: true,
      category,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error updating match category',
      error: err.message,
    });
  }
});

/// @route   DELETE /api/categories/match/:categoryId
/// @desc    Delete match category
/// @access  Private
router.delete('/match/:categoryId', authenticateToken, async (req, res) => {
  try {
    // Delete category
    await MatchCategory.findByIdAndDelete(req.params.categoryId);

    // Delete all categorized matches in this category
    await CategorizedMatch.deleteMany({ categoryId: req.params.categoryId });

    res.json({
      success: true,
      message: 'Match category deleted',
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error deleting match category',
      error: err.message,
    });
  }
});

/// @route   POST /api/categories/match/assign
/// @desc    Assign match to category
/// @access  Private
router.post('/match/assign', authenticateToken, async (req, res) => {
  try {
    const { matchId, userId, otherUserId, categoryId, isPinned, notes } = req.body;

    // Check if already categorized
    let categorized = await CategorizedMatch.findOne({ matchId, categoryId });

    if (!categorized) {
      categorized = new CategorizedMatch({
        matchId,
        userId,
        otherUserId,
        categoryId,
        isPinned,
        notes,
        categorizedAt: new Date(),
      });
      await categorized.save();

      // Increment match count in category
      await MatchCategory.findByIdAndUpdate(
        categoryId,
        { $inc: { matchCount: 1 } }
      );
    }

    res.status(201).json({
      success: true,
      categorized,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error assigning match to category',
      error: err.message,
    });
  }
});

/// @route   GET /api/categories/match/:categoryId/matches
/// @desc    Get all matches in category
/// @access  Private
router.get('/match/:categoryId/matches', authenticateToken, async (req, res) => {
  try {
    const matches = await CategorizedMatch.find({
      categoryId: req.params.categoryId,
    }).sort({ isPinned: -1, categorizedAt: -1 });

    res.json({
      success: true,
      matches,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error fetching matches',
      error: err.message,
    });
  }
});

/// @route   PUT /api/categories/match/:matchId/pin
/// @desc    Pin/unpin match in category
/// @access  Private
router.put('/match/:matchId/pin', authenticateToken, async (req, res) => {
  try {
    const { isPinned } = req.body;

    const match = await CategorizedMatch.findByIdAndUpdate(
      req.params.matchId,
      { isPinned },
      { new: true }
    );

    res.json({
      success: true,
      match,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error updating pin status',
      error: err.message,
    });
  }
});

export default router;
