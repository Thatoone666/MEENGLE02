import express from 'express';
import mongoose from 'mongoose';
import { verifyToken } from './auth.js';

const router = express.Router();

const messageSchema = new mongoose.Schema({
  senderId: mongoose.Schema.Types.ObjectId,
  receiverId: mongoose.Schema.Types.ObjectId,
  message: { type: String, required: true },
  timestamp: { type: Date, default: Date.now, index: true },
  read: { type: Boolean, default: false },
  deleted: { type: Boolean, default: false },
  edited: Boolean,
  editedAt: Date
});

messageSchema.index({ senderId: 1, receiverId: 1, timestamp: -1 });
messageSchema.index({ receiverId: 1, read: 1 });

let Message;
try {
  Message = mongoose.model('Message', messageSchema);
} catch {
  Message = mongoose.model('Message');
}

router.get('/history/:otherUserId', verifyToken, async (req, res) => {
  try {
    const { otherUserId } = req.params;
    const limit = Math.min(parseInt(req.query.limit) || 50, 200);
    const skip = parseInt(req.query.skip) || 0;

    if (!mongoose.Types.ObjectId.isValid(otherUserId)) {
      return res.status(400).json({ error: 'Invalid user ID' });
    }

    const senderId = new mongoose.Types.ObjectId(req.userId);
    const receiverId = new mongoose.Types.ObjectId(otherUserId);

    const messages = await Message.find({
      $or: [
        { senderId, receiverId },
        { senderId: receiverId, receiverId: senderId }
      ],
      deleted: false
    })
      .sort({ timestamp: 1 })
      .limit(limit)
      .skip(skip)
      .lean();

    const total = await Message.countDocuments({
      $or: [
        { senderId, receiverId },
        { senderId: receiverId, receiverId: senderId }
      ],
      deleted: false
    });

    await Message.updateMany(
      { receiverId: senderId, senderId: receiverId, read: false },
      { read: true }
    );

    res.json({
      messages,
      total,
      limit,
      skip
    });
  } catch (error) {
    console.error('Chat history error:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

router.get('/conversations', verifyToken, async (req, res) => {
  try {
    const senderId = new mongoose.Types.ObjectId(req.userId);

    const messages = await Message.find({
      $or: [{ senderId }, { receiverId: senderId }],
      deleted: false
    })
      .sort({ timestamp: -1 })
      .lean();

    const conversations = {};

    messages.forEach(msg => {
      const partnerId = msg.senderId.toString() === senderId.toString() 
        ? msg.receiverId.toString() 
        : msg.senderId.toString();

      if (!conversations[partnerId]) {
        conversations[partnerId] = {
          partnerId,
          lastMessage: msg.message,
          lastTimestamp: msg.timestamp,
          unreadCount: msg.receiverId.toString() === senderId.toString() && !msg.read ? 1 : 0
        };
      } else if (msg.receiverId.toString() === senderId.toString() && !msg.read) {
        conversations[partnerId].unreadCount += 1;
      }
    });

    const result = Object.values(conversations)
      .sort((a, b) => b.lastTimestamp - a.lastTimestamp)
      .slice(0, 50);

    res.json(result);
  } catch (error) {
    console.error('Conversations error:', error);
    res.status(500).json({ error: 'Failed to fetch conversations' });
  }
});

router.post('/send', verifyToken, async (req, res) => {
  try {
    const { receiverId, message } = req.body;

    if (!receiverId || !message) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (!mongoose.Types.ObjectId.isValid(receiverId)) {
      return res.status(400).json({ error: 'Invalid receiver ID' });
    }

    if (message.trim().length === 0 || message.length > 5000) {
      return res.status(400).json({ error: 'Message must be 1-5000 characters' });
    }

    const senderId = new mongoose.Types.ObjectId(req.userId);
    const receiverObjectId = new mongoose.Types.ObjectId(receiverId);

    if (senderId.toString() === receiverObjectId.toString()) {
      return res.status(400).json({ error: 'Cannot message yourself' });
    }

    const msg = new Message({
      senderId,
      receiverId: receiverObjectId,
      message: message.trim()
    });

    await msg.save();

    res.json({
      success: true,
      message: {
        id: msg._id,
        senderId: msg.senderId,
        receiverId: msg.receiverId,
        message: msg.message,
        timestamp: msg.timestamp,
        read: false
      }
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
});

router.put('/message/:messageId', verifyToken, async (req, res) => {
  try {
    const { messageId } = req.params;
    const { message } = req.body;

    if (!message || message.trim().length === 0 || message.length > 5000) {
      return res.status(400).json({ error: 'Invalid message' });
    }

    if (!mongoose.Types.ObjectId.isValid(messageId)) {
      return res.status(400).json({ error: 'Invalid message ID' });
    }

    const senderId = new mongoose.Types.ObjectId(req.userId);

    const updated = await Message.findOneAndUpdate(
      { _id: messageId, senderId },
      { message: message.trim(), edited: true, editedAt: new Date() },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ error: 'Message not found or unauthorized' });
    }

    res.json({ success: true, message: updated });
  } catch (error) {
    console.error('Edit message error:', error);
    res.status(500).json({ error: 'Failed to edit message' });
  }
});

router.delete('/message/:messageId', verifyToken, async (req, res) => {
  try {
    const { messageId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(messageId)) {
      return res.status(400).json({ error: 'Invalid message ID' });
    }

    const senderId = new mongoose.Types.ObjectId(req.userId);

    const result = await Message.findOneAndUpdate(
      { _id: messageId, senderId },
      { deleted: true, message: '[Deleted]' },
      { new: true }
    );

    if (!result) {
      return res.status(404).json({ error: 'Message not found or unauthorized' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Delete message error:', error);
    res.status(500).json({ error: 'Failed to delete message' });
  }
});

router.post('/mark-read', verifyToken, async (req, res) => {
  try {
    const { conversationId } = req.body;

    if (!mongoose.Types.ObjectId.isValid(conversationId)) {
      return res.status(400).json({ error: 'Invalid conversation ID' });
    }

    const receiverId = new mongoose.Types.ObjectId(req.userId);
    const senderId = new mongoose.Types.ObjectId(conversationId);

    const result = await Message.updateMany(
      { senderId, receiverId, read: false },
      { read: true }
    );

    res.json({ 
      success: true, 
      updated: result.modifiedCount 
    });
  } catch (error) {
    console.error('Mark read error:', error);
    res.status(500).json({ error: 'Failed to mark messages as read' });
  }
});

router.get('/unread-count', verifyToken, async (req, res) => {
  try {
    const receiverId = new mongoose.Types.ObjectId(req.userId);

    const count = await Message.countDocuments({
      receiverId,
      read: false,
      deleted: false
    });

    res.json({ unreadCount: count });
  } catch (error) {
    console.error('Unread count error:', error);
    res.status(500).json({ error: 'Failed to fetch unread count' });
  }
});

export default router;
export { Message };
