import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: [
      'match',
      'message',
      'like',
      'visit',
      'milestone',
      'feature',
      'promotion'
    ],
    required: true
  },
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  relatedUserId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  relatedItemId: String,
  read: {
    type: Boolean,
    default: false
  },
  readAt: Date,
  link: String,
  data: mongoose.Schema.Types.Mixed,
  createdAt: {
    type: Date,
    default: Date.now,
    expire: 30 * 24 * 60 * 60 // Auto-delete after 30 days
  }
});

const Notification = mongoose.model('Notification', notificationSchema);

export default Notification;
