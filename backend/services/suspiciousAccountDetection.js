import mongoose from 'mongoose';

const suspiciousAccountSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  score: { type: Number, default: 0 },
  flags: [String],
  flaggedAt: { type: Date, default: Date.now },
  reviewed: { type: Boolean, default: false },
  reviewedBy: mongoose.Schema.Types.ObjectId,
  reviewedAt: Date,
  action: { type: String, enum: ['none', 'warning', 'suspension', 'ban'] },
  metadata: mongoose.Schema.Types.Mixed
});

let SuspiciousAccount;
try {
  SuspiciousAccount = mongoose.model('SuspiciousAccount', suspiciousAccountSchema);
} catch {
  SuspiciousAccount = mongoose.model('SuspiciousAccount');
}

export const analyzeUserBehavior = async (userId) => {
  try {
    const User = mongoose.model('User');
    const Message = mongoose.model('Message');
    const UserMatch = mongoose.model('UserMatch');
    const FraudReport = mongoose.model('FraudReport');

    const user = await User.findById(userId);
    if (!user) return null;

    let score = 0;
    const flags = [];

    if (!user.emailVerified) {
      score += 10;
      flags.push('unverified_email');
    }

    if (!user.photos || user.photos.length === 0) {
      score += 15;
      flags.push('no_photos');
    } else if (user.photos.length === 1) {
      score += 5;
      flags.push('only_one_photo');
    }

    if (!user.bio || user.bio.trim().length < 20) {
      score += 8;
      flags.push('minimal_bio');
    }

    const messageCount = await Message.countDocuments({
      $or: [{ senderId: userId }, { receiverId: userId }]
    });

    const likeCount = await UserMatch.countDocuments({
      userId,
      action: 'like'
    });

    if (messageCount === 0 && likeCount === 0 && user.createdAt) {
      const daysSinceCreation = Math.floor((Date.now() - user.createdAt) / (24 * 60 * 60 * 1000));
      if (daysSinceCreation > 7) {
        score += 10;
        flags.push('inactive_week');
      }
    }

    if (likeCount > 50 && messageCount < 5) {
      score += 20;
      flags.push('mass_liking_no_engagement');
    }

    const reportsAboutUser = await FraudReport.countDocuments({
      reportedUser: userId,
      status: { $in: ['open', 'investigating'] }
    });

    if (reportsAboutUser > 0) {
      score += reportsAboutUser * 15;
      flags.push(`${reportsAboutUser}_active_reports`);
    }

    if (user.createdAt) {
      const accountAge = Math.floor((Date.now() - user.createdAt) / (24 * 60 * 60 * 1000));
      if (accountAge < 1) {
        score += 15;
        flags.push('brand_new_account');
      }
    }

    if (score >= 40) {
      const existing = await SuspiciousAccount.findOne({ userId, reviewed: false });

      if (!existing) {
        const suspicious = new SuspiciousAccount({
          userId,
          score,
          flags,
          metadata: {
            messageCount,
            likeCount,
            photoCount: user.photos?.length || 0,
            reportsCount: reportsAboutUser
          }
        });

        await suspicious.save();
        return suspicious;
      } else {
        await SuspiciousAccount.updateOne(
          { _id: existing._id },
          { score, flags }
        );
        return existing;
      }
    }

    return null;
  } catch (error) {
    console.error('Analyze user behavior error:', error);
    return null;
  }
};

export const getSuspiciousAccounts = async (limit = 50, skip = 0) => {
  try {
    const accounts = await SuspiciousAccount.find({ reviewed: false })
      .sort({ score: -1 })
      .limit(limit)
      .skip(skip)
      .lean();

    const total = await SuspiciousAccount.countDocuments({ reviewed: false });

    return { accounts, total };
  } catch (error) {
    console.error('Get suspicious accounts error:', error);
    return { accounts: [], total: 0 };
  }
};

export const reviewSuspiciousAccount = async (accountId, action, reviewedBy) => {
  try {
    const account = await SuspiciousAccount.findByIdAndUpdate(
      accountId,
      {
        reviewed: true,
        reviewedAt: new Date(),
        reviewedBy,
        action
      },
      { new: true }
    );

    if (action === 'suspension') {
      const User = mongoose.model('User');
      await User.findByIdAndUpdate(account.userId, {
        suspended: true,
        suspendReason: 'Suspicious behavior detected'
      });
    }

    return account;
  } catch (error) {
    console.error('Review account error:', error);
    return null;
  }
};

export default SuspiciousAccount;
