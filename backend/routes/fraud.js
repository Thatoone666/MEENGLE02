import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';
import { sendReportNotificationEmail } from '../services/emailService.js';

const router = express.Router();

const fraudSchema = new mongoose.Schema({
  reportedBy: mongoose.Schema.Types.ObjectId,
  reportedUser: mongoose.Schema.Types.ObjectId,
  reason: { type: String, enum: ['fake_profile', 'scam', 'harassment', 'inappropriate_content', 'other'] },
  details: String,
  evidence: [String],
  status: { type: String, enum: ['open', 'investigating', 'resolved', 'dismissed'], default: 'open' },
  riskScore: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
  resolvedAt: Date,
  resolvedBy: mongoose.Schema.Types.ObjectId,
  resolution: String
});

fraudSchema.index({ reportedUser: 1, status: 1 });
fraudSchema.index({ reportedBy: 1, createdAt: -1 });
fraudSchema.index({ riskScore: -1 });

let FraudReport;
try {
  FraudReport = mongoose.model('FraudReport', fraudSchema);
} catch {
  FraudReport = mongoose.model('FraudReport');
}

router.post('/report', verifyToken, async (req, res) => {
  try {
    const { reportedUser, reason, details, evidence } = req.body;

    if (!reportedUser || !reason) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const validReasons = ['fake_profile', 'scam', 'harassment', 'inappropriate_content', 'other'];
    if (!validReasons.includes(reason)) {
      return res.status(400).json({ error: 'Invalid reason' });
    }

    if (!mongoose.Types.ObjectId.isValid(reportedUser)) {
      return res.status(400).json({ error: 'Invalid user ID' });
    }

    const reportedById = new mongoose.Types.ObjectId(req.userId);
    const reportedUserId = new mongoose.Types.ObjectId(reportedUser);

    if (reportedById.toString() === reportedUserId.toString()) {
      return res.status(400).json({ error: 'Cannot report yourself' });
    }

    const riskScore = calculateRiskScore(reason);

    const report = new FraudReport({
      reportedBy: reportedById,
      reportedUser: reportedUserId,
      reason,
      details: details || '',
      evidence: evidence || [],
      riskScore,
      status: 'open'
    });

    await report.save();

    if (riskScore >= 7) {
      await sendReportNotificationEmail(process.env.ADMIN_EMAIL || 'admin@meengle.app', {
        reportedUserId: reportedUserId.toString(),
        reason,
        details,
        riskScore
      }).catch(err => console.error('Email notification error:', err));
    }

    res.json({
      success: true,
      report: {
        id: report._id,
        reportedUser: report.reportedUser,
        reason: report.reason,
        status: report.status,
        riskScore: report.riskScore,
        createdAt: report.createdAt
      }
    });
  } catch (error) {
    console.error('Report fraud error:', error);
    res.status(500).json({ error: 'Failed to submit report' });
  }
});

router.get('/status/:reportId', verifyToken, async (req, res) => {
  try {
    const { reportId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(reportId)) {
      return res.status(400).json({ error: 'Invalid report ID' });
    }

    const report = await FraudReport.findById(reportId);

    if (!report) {
      return res.status(404).json({ error: 'Report not found' });
    }

    if (report.reportedBy.toString() !== req.userId) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    res.json(report);
  } catch (error) {
    console.error('Get report error:', error);
    res.status(500).json({ error: 'Failed to fetch report' });
  }
});

router.get('/user-reports/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: 'Invalid user ID' });
    }

    const reports = await FraudReport.find({ reportedUser: userId })
      .sort({ createdAt: -1 })
      .select('reason riskScore status createdAt')
      .lean();

    const totalReports = reports.length;
    const highRiskReports = reports.filter(r => r.riskScore >= 7).length;
    const avgRiskScore = reports.reduce((sum, r) => sum + r.riskScore, 0) / Math.max(reports.length, 1);

    res.json({
      totalReports,
      highRiskReports,
      avgRiskScore: parseFloat(avgRiskScore.toFixed(2)),
      reports
    });
  } catch (error) {
    console.error('Get user reports error:', error);
    res.status(500).json({ error: 'Failed to fetch reports' });
  }
});

router.post('/resolve/:reportId', verifyToken, async (req, res) => {
  try {
    const { reportId } = req.params;
    const { status, resolution } = req.body;

    if (!['resolved', 'dismissed'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    if (!mongoose.Types.ObjectId.isValid(reportId)) {
      return res.status(400).json({ error: 'Invalid report ID' });
    }

    const adminId = new mongoose.Types.ObjectId(req.userId);

    const report = await FraudReport.findByIdAndUpdate(
      reportId,
      {
        status: 'investigating',
        resolvedAt: new Date(),
        resolvedBy: adminId,
        resolution
      },
      { new: true }
    );

    if (!report) {
      return res.status(404).json({ error: 'Report not found' });
    }

    res.json({ success: true, report });
  } catch (error) {
    console.error('Resolve report error:', error);
    res.status(500).json({ error: 'Failed to resolve report' });
  }
});

function calculateRiskScore(reason) {
  const scores = {
    fake_profile: 8,
    scam: 10,
    harassment: 7,
    inappropriate_content: 6,
    other: 3
  };
  return scores[reason] || 3;
}

export default router;