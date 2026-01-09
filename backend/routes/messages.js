import express from 'express';
import { authenticateToken } from '../middleware/auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const messageSchema = new mongoose.Schema({
  fromUserId: String,
  toUserId: String,
  type: String, // 'text', 'image', 'location_share', etc.
  content: String,
  locationData: { latitude: Number, longitude: Number },
  serviceType: String,
  timestamp: { type: Date, default: Date.now },
  isEmergency: { type: Boolean, default: false },
  priority: { type: String, default: 'normal' },
  read: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

let Message;
try {
  Message = mongoose.model('Message', messageSchema);
} catch {
  Message = mongoose.model('Message');
}

/// @route   POST /api/messages/send
/// @desc    Send a message (including location shares)
/// @access  Private
router.post('/send', authenticateToken, async (req, res) => {
  try {
    const {
      fromUserId,
      toUserId,
      type,
      content,
      locationData,
      serviceType,
      timestamp,
      isEmergency,
      priority,
    } = req.body;

    // Create message
    const message = new Message({
      fromUserId,
      toUserId,
      type, // 'text', 'image', 'location_share', etc.
      content,
      locationData,
      serviceType,
      timestamp: new Date(timestamp),
      isEmergency: isEmergency || false,
      priority: priority || 'normal',
      read: false,
      createdAt: new Date(),
    });

    await message.save();

    // ? Send via WebSocket in real-time
    io.to(toUserId).emit('new_message', {
      id: message._id,
      from: fromUserId,
      type,
      content,
      locationData,
      isEmergency,
      priority,
      timestamp: message.timestamp,
    });

    // ? Send push notification for emergency messages
    if (isEmergency) {
      await sendEmergencyNotification(toUserId, fromUserId, content);
    }

    res.status(201).json({
      success: true,
      message,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error sending message',
      error: err.message,
    });
  }
});

/// @route   GET /api/messages/:userId
/// @desc    Get messages for a user
/// @access  Private
router.get('/:userId', authenticateToken, async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [{ fromUserId: req.params.userId }, { toUserId: req.params.userId }],
    })
      .sort({ createdAt: -1 })
      .limit(100);

    res.json({
      success: true,
      messages,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error fetching messages',
      error: err.message,
    });
  }
});

/// @route   GET /api/messages/conversation/:otherUserId
/// @desc    Get conversation with specific user
/// @access  Private
router.get('/conversation/:otherUserId', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const otherUserId = req.params.otherUserId;

    const messages = await Message.find({
      $or: [
        { fromUserId: userId, toUserId: otherUserId },
        { fromUserId: otherUserId, toUserId: userId },
      ],
    }).sort({ createdAt: 1 });

    res.json({
      success: true,
      messages,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error fetching conversation',
      error: err.message,
    });
  }
});

/// @route   PUT /api/messages/:messageId/read
/// @desc    Mark message as read
/// @access  Private
router.put('/:messageId/read', authenticateToken, async (req, res) => {
  try {
    const message = await Message.findByIdAndUpdate(
      req.params.messageId,
      { read: true, readAt: new Date() },
      { new: true }
    );

    res.json({
      success: true,
      message,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error updating message',
      error: err.message,
    });
  }
});

/// @route   GET /api/messages/:userId/unread
/// @desc    Get unread message count
/// @access  Private
router.get('/:userId/unread', authenticateToken, async (req, res) => {
  try {
    const unreadCount = await Message.countDocuments({
      toUserId: req.params.userId,
      read: false,
    });

    // Count emergency unread separately
    const emergencyCount = await Message.countDocuments({
      toUserId: req.params.userId,
      read: false,
      isEmergency: true,
    });

    res.json({
      success: true,
      unreadCount,
      emergencyCount,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error fetching unread count',
      error: err.message,
    });
  }
});

/// @route   DELETE /api/messages/:messageId
/// @desc    Delete a message
/// @access  Private
router.delete('/:messageId', authenticateToken, async (req, res) => {
  try {
    await Message.findByIdAndDelete(req.params.messageId);

    res.json({
      success: true,
      message: 'Message deleted',
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: 'Error deleting message',
      error: err.message,
    });
  }
});

// Helper: Send emergency notification
async function sendEmergencyNotification(toUserId, fromUserId, content) {
  try {
    // Send push notification
    // Send SMS notification
    // Send email notification
    console.log(`[EMERGENCY] Message from ${fromUserId} to ${toUserId}`);
  } catch (err) {
    console.error('Error sending notification:', err);
  }
}

export default router;
