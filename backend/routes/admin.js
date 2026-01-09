import express from 'express';
import mongoose from 'mongoose';
import { verifyToken } from './auth.js';

const router = express.Router();

const adminSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  role: { type: String, enum: ['admin', 'moderator'], required: true },
  permissions: [String],
  createdAt: { type: Date, default: Date.now }
});

let Admin;
try {
  Admin = mongoose.model('Admin', adminSchema);
} catch {
  Admin = mongoose.model('Admin');
}

const adminMiddleware = async (req, res, next) => {
  try {
    const admin = await Admin.findOne({ userId: req.userId });
    if (!admin) {
      return res.status(403).json({ error: 'Admin access required' });
    }
    req.admin = admin;
    next();
  } catch (error) {
    res.status(500).json({ error: 'Admin verification failed' });
  }
};

router.get('/dashboard', verifyToken, adminMiddleware, async (req, res) => {
  try {
    const User = mongoose.model('User');
    const FraudReport = mongoose.model('FraudReport');
    const Subscription = mongoose.model('Subscription');
    const Message = mongoose.model('Message');

    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ lastLogin: { $gt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } });
    const totalReports = await FraudReport.countDocuments();
    const openReports = await FraudReport.countDocuments({ status: 'open' });
    const totalMessages = await Message.countDocuments();
    const premiumUsers = await Subscription.countDocuments({ status: 'active', tier: { $ne: 'free' } });

    const highRiskUsers = await FraudReport.aggregate([
      { $group: { _id: '$reportedUser', count: { $sum: 1 }, avgScore: { $avg: '$riskScore' } } },
      { $match: { avgScore: { $gte: 7 } } },
      { $sort: { avgScore: -1 } },
      { $limit: 10 }
    ]);

    res.json({
      stats: {
        totalUsers,
        activeUsers,
        premiumUsers,
        totalReports,
        openReports,
        totalMessages
      },
      highRiskUsers
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard' });
  }
});

router.get('/users', verifyToken, adminMiddleware, async (req, res) => {
  try {
    const User = mongoose.model('User');
    const limit = Math.min(parseInt(req.query.limit) || 50, 200);
    const skip = parseInt(req.query.skip) || 0;

    const users = await User.find()
      .select('-password')
      .limit(limit)
      .skip(skip)
      .lean();

    const total = await User.countDocuments();

    res.json({ users, total, limit, skip });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

router.post('/users/:userId/suspend', verifyToken, adminMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason } = req.body;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: 'Invalid user ID' });
    }

    const User = mongoose.model('User');
    const user = await User.findByIdAndUpdate(
      userId,
      {
        suspended: true,
        suspendedAt: new Date(),
        suspendReason: reason
      },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ success: true, user });
  } catch (error) {
    console.error('Suspend user error:', error);
    res.status(500).json({ error: 'Failed to suspend user' });
  }
});

router.post('/users/:userId/unsuspend', verifyToken, adminMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: 'Invalid user ID' });
    }

    const User = mongoose.model('User');
    const user = await User.findByIdAndUpdate(
      userId,
      {
        suspended: false,
        suspendedAt: null,
        suspendReason: null
      },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ success: true, user });
  } catch (error) {
    console.error('Unsuspend user error:', error);
    res.status(500).json({ error: 'Failed to unsuspend user' });
  }
});

router.get('/reports', verifyToken, adminMiddleware, async (req, res) => {
  try {
    const FraudReport = mongoose.model('FraudReport');
    const status = req.query.status || 'open';
    const limit = Math.min(parseInt(req.query.limit) || 50, 200);
    const skip = parseInt(req.query.skip) || 0;

    const reports = await FraudReport.find({ status })
      .sort({ riskScore: -1, createdAt: -1 })
      .limit(limit)
      .skip(skip)
      .lean();

    const total = await FraudReport.countDocuments({ status });

    res.json({ reports, total, limit, skip });
  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({ error: 'Failed to fetch reports' });
  }
});

router.get('/analytics/revenue', verifyToken, adminMiddleware, async (req, res) => {
  try {
    const Invoice = mongoose.model('Invoice');
    const Subscription = mongoose.model('Subscription');

    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const revenue = await Invoice.aggregate([
      { $match: { completedAt: { $gte: thirtyDaysAgo }, status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' }, count: { $sum: 1 } } }
    ]);

    const subscriptions = await Subscription.aggregate([
      { $group: { _id: '$tier', count: { $sum: 1 } } }
    ]);

    const churn = await Subscription.countDocuments({
      status: 'cancelled',
      cancellationDate: { $gte: thirtyDaysAgo }
    });

    res.json({
      revenue: revenue[0] || { total: 0, count: 0 },
      subscriptions,
      churnRate: churn
    });
  } catch (error) {
    console.error('Analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
});

router.get('/analytics/engagement', verifyToken, adminMiddleware, async (req, res) => {
  try {
    const Message = mongoose.model('Message');
    const UserMatch = mongoose.model('UserMatch');

    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

    const messagesPerDay = await Message.aggregate([
      { $match: { timestamp: { $gte: sevenDaysAgo } } },
      { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp' } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);

    const likesPerDay = await UserMatch.aggregate([
      { $match: { timestamp: { $gte: sevenDaysAgo }, action: 'like' } },
      { $group: { _id: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp' } }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);

    res.json({
      messagesPerDay,
      likesPerDay
    });
  } catch (error) {
    console.error('Engagement analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch engagement data' });
  }
});

export default router;
export { adminMiddleware };
