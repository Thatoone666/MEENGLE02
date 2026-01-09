import express from 'express';
import mongoose from 'mongoose';
import { verifyToken } from './auth.js';

const router = express.Router();

const matchSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  targetUserId: mongoose.Schema.Types.ObjectId,
  action: { type: String, enum: ['like', 'pass'], required: true },
  timestamp: { type: Date, default: Date.now, index: true }
});

const mutualMatchSchema = new mongoose.Schema({
  userId1: mongoose.Schema.Types.ObjectId,
  userId2: mongoose.Schema.Types.ObjectId,
  matchedAt: { type: Date, default: Date.now, index: true }
});

matchSchema.index({ userId: 1, targetUserId: 1 });
matchSchema.index({ userId: 1, action: 1 });
mutualMatchSchema.index({ userId1: 1, userId2: 1 });

let UserMatch, MutualMatch, User;

try {
  UserMatch = mongoose.model('UserMatch', matchSchema);
} catch {
  UserMatch = mongoose.model('UserMatch');
}

try {
  MutualMatch = mongoose.model('MutualMatch', mutualMatchSchema);
} catch {
  MutualMatch = mongoose.model('MutualMatch');
}

try {
  User = mongoose.model('User');
} catch {
  console.error('User model not found');
}

// Get potential matches with distance and filter preferences
router.get('/potential', verifyToken, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.userId);
    const currentUser = await User.findById(userId).lean();
    
    if (!currentUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (!currentUser.location || !currentUser.location.coordinates) {
      return res.status(400).json({ error: 'User location not set' });
    }

    // Get already acted on users
    const acted = await UserMatch.find({ userId }).select('targetUserId').lean();
    const actedIds = acted.map(m => m.targetUserId);

    // Get mutual matches
    const mutual = await MutualMatch.find({
      $or: [{ userId1: userId }, { userId2: userId }]
    }).lean();
    
    const mutualIds = mutual.map(m => 
      m.userId1.toString() === userId.toString() ? m.userId2 : m.userId1
    );

    const excludeIds = [userId, ...actedIds, ...mutualIds];

    // Get max distance preference (default 50km)
    const maxDistance = currentUser.filterPreferences?.maxDistance || 50;

    // Build filter query
    const filterQuery = {
      _id: { $nin: excludeIds },
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: currentUser.location.coordinates
          },
          $maxDistance: maxDistance * 1000 // convert km to meters
        }
      }
    };

    // Add gender preference
    if (currentUser.genderPreference && currentUser.genderPreference !== 'Any') {
      filterQuery.gender = currentUser.genderPreference;
    }

    // Add age range preference
    if (currentUser.ageRange) {
      filterQuery.age = {
        $gte: currentUser.ageRange.min || 18,
        $lte: currentUser.ageRange.max || 99
      };
    }

    // Add filter preferences if they exist
    if (currentUser.filterPreferences) {
      const fp = currentUser.filterPreferences;
      
      if (fp.religions && fp.religions.length > 0) {
        filterQuery.religion = { $in: fp.religions };
      }
      
      if (fp.bodyTypes && fp.bodyTypes.length > 0) {
        filterQuery.bodyType = { $in: fp.bodyTypes };
      }
      
      if (fp.educationLevels && fp.educationLevels.length > 0) {
        filterQuery.educationLevel = { $in: fp.educationLevels };
      }
      
      if (fp.relationshipGoals && fp.relationshipGoals.length > 0) {
        filterQuery.relationshipGoal = { $in: fp.relationshipGoals };
      }
    }

    // Find potential matches with geospatial query
    const potentialMatches = await User.find(filterQuery)
      .select('-password -refreshToken')
      .limit(10)
      .lean();

    res.json(potentialMatches);
  } catch (error) {
    console.error('Potential matches error:', error);
    res.status(500).json({ error: 'Failed to fetch matches' });
  }
});

// Like a user
router.post('/like', verifyToken, async (req, res) => {
  try {
    const { targetUserId } = req.body;

    if (!targetUserId) {
      return res.status(400).json({ error: 'targetUserId required' });
    }

    if (!mongoose.Types.ObjectId.isValid(targetUserId)) {
      return res.status(400).json({ error: 'Invalid targetUserId' });
    }

    const userId = new mongoose.Types.ObjectId(req.userId);
    const targetId = new mongoose.Types.ObjectId(targetUserId);

    if (userId.toString() === targetId.toString()) {
      return res.status(400).json({ error: 'Cannot like yourself' });
    }

    const existing = await UserMatch.findOne({
      userId,
      targetUserId: targetId
    });

    if (existing) {
      return res.status(400).json({ error: 'Already acted on this user' });
    }

    await UserMatch.create({
      userId,
      targetUserId: targetId,
      action: 'like'
    });

    // Check if target also liked current user
    const targetLike = await UserMatch.findOne({
      userId: targetId,
      targetUserId: userId,
      action: 'like'
    });

    if (targetLike) {
      // Create mutual match
      const match = await MutualMatch.create({
        userId1: userId,
        userId2: targetId
      });

      return res.json({
        success: true,
        mutualMatch: true,
        message: 'It\'s a match!',
        matchId: match._id
      });
    }

    res.json({
      success: true,
      mutualMatch: false,
      message: 'Like recorded'
    });
  } catch (error) {
    console.error('Like error:', error);
    res.status(500).json({ error: 'Failed to record like' });
  }
});

// Pass on a user
router.post('/pass', verifyToken, async (req, res) => {
  try {
    const { targetUserId } = req.body;

    if (!targetUserId) {
      return res.status(400).json({ error: 'targetUserId required' });
    }

    if (!mongoose.Types.ObjectId.isValid(targetUserId)) {
      return res.status(400).json({ error: 'Invalid targetUserId' });
    }

    const userId = new mongoose.Types.ObjectId(req.userId);
    const targetId = new mongoose.Types.ObjectId(targetUserId);

    const existing = await UserMatch.findOne({
      userId,
      targetUserId: targetId
    });

    if (existing) {
      return res.status(400).json({ error: 'Already acted on this user' });
    }

    await UserMatch.create({
      userId,
      targetUserId: targetId,
      action: 'pass'
    });

    res.json({ success: true, message: 'Pass recorded' });
  } catch (error) {
    console.error('Pass error:', error);
    res.status(500).json({ error: 'Failed to record pass' });
  }
});

// Get matches (mutual matches)
router.get('/matches', verifyToken, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.userId);

    const matches = await MutualMatch.find({
      $or: [{ userId1: userId }, { userId2: userId }]
    }).lean();

    const matchIds = matches.map(m => 
      m.userId1.toString() === userId.toString() ? m.userId2 : m.userId1
    );

    const matchedUsers = await User.find({ 
      _id: { $in: matchIds } 
    })
      .select('-password')
      .lean();

    res.json(matchedUsers);
  } catch (error) {
    console.error('Get matches error:', error);
    res.status(500).json({ error: 'Failed to fetch matches' });
  }
});

// Get match count
router.get('/count', verifyToken, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.userId);

    const matchCount = await MutualMatch.countDocuments({
      $or: [{ userId1: userId }, { userId2: userId }]
    });

    res.json({ count: matchCount });
  } catch (error) {
    console.error('Match count error:', error);
    res.status(500).json({ error: 'Failed to fetch match count' });
  }
});

export default router;
