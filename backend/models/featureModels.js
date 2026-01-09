const mongoose = require('mongoose');

// Moments Schema - 24h temporary matches with countdown
const MomentSchema = new mongoose.Schema({
  id: { type: String, unique: true },
  fromUserId: String,
  toUserId: String,
  matchReason: String,
  description: String,
  status: { type: String, enum: ['active', 'accepted', 'expired'], default: 'active' },
  createdAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, default: () => new Date(Date.now() + 24 * 60 * 60 * 1000) },
  extensions: { type: Number, default: 0 },
  maxExtensions: { type: Number, default: 1 },
  answeredPrompts: { type: Number, default: 0 },
}, { timestamps: true });

// Notes Schema - Anonymous profile comments
const NoteSchema = new mongoose.Schema({
  id: { type: String, unique: true },
  fromUserId: String,
  toUserId: String,
  content: String,
  type: { type: String, enum: ['compliment', 'question', 'comment'], default: 'comment' },
  likes: { type: Number, default: 0 },
  likedBy: [String], // User IDs who liked this note
  isAnonymous: { type: Boolean, default: true },
  replies: [String], // Note IDs of replies
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

// Circles Schema - Interest communities
const CircleSchema = new mongoose.Schema({
  id: { type: String, unique: true },
  name: String,
  description: String,
  category: String,
  imageUrl: String,
  memberCount: { type: Number, default: 0 },
  members: [String], // User IDs
  tags: [String],
  isOfficial: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

// CirclePost Schema - Posts in communities
const CirclePostSchema = new mongoose.Schema({
  id: { type: String, unique: true },
  circleId: String,
  userId: String,
  content: String,
  mediaUrl: String,
  likes: { type: Number, default: 0 },
  comments: [String], // Comment IDs
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

// Stories Schema - 24h ephemeral content
const StorySchema = new mongoose.Schema({
  id: { type: String, unique: true },
  userId: String,
  userName: String, // User's display name
  userProfilePic: String, // User's profile photo URL
  mediaUrl: String,
  mediaType: { type: String, enum: ['image', 'video', 'text'], default: 'image' },
  caption: String,
  createdAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, default: () => new Date(Date.now() + 24 * 60 * 60 * 1000) },
  viewCount: { type: Number, default: 0 },
  likeCount: { type: Number, default: 0 },
  viewedByUserIds: [String],
  likedByUserIds: [String],
}, { timestamps: true });

// Dates Schema - Date suggestions and proposals
const DateSchema = new mongoose.Schema({
  id: { type: String, unique: true },
  fromUserId: String,
  toUserId: String,
  title: String,
  description: String,
  location: String,
  suggestedTime: Date,
  vibe: String, // 'casual', 'romantic', 'fun', etc.
  status: { type: String, enum: ['pending', 'accepted', 'declined', 'completed'], default: 'pending' },
  timeEstimate: String,
  vibeMatch: { type: Number, default: 0 }, // compatibility score
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

// Spotlight Schema - Premium visibility boosts
const SpotlightSchema = new mongoose.Schema({
  id: { type: String, unique: true },
  userId: String,
  tier: { type: String, enum: ['bronze', 'silver', 'gold', 'platinum'], default: 'bronze' },
  isActive: { type: Boolean, default: false },
  purchaseDate: Date,
  expiresAt: Date,
  viewCount: { type: Number, default: 0 },
  passCount: { type: Number, default: 0 },
  stats: {
    totalViews: { type: Number, default: 0 },
    viewsPerDay: { type: Number, default: 0 },
    totalPasses: { type: Number, default: 0 },
  },
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

// Roam Schema - Travel mode profiles
const RoamSchema = new mongoose.Schema({
  id: { type: String, unique: true },
  userId: String,
  isActive: { type: Boolean, default: false },
  currentCity: String,
  latitude: Number,
  longitude: Number,
  activatedAt: { type: Date, default: Date.now },
  endDate: Date,
  travelInterests: [String],
  lookingFor: [String],
  durationFormatted: String,
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

// Discovery Match Schema - Matching algorithm results
const MatchSchema = new mongoose.Schema({
  id: { type: String, unique: true },
  userId: String,
  matchedUserId: String,
  matchScore: { type: Number, default: 0 }, // 0-100
  matchReasons: [String],
  isVerified: { type: Boolean, default: false },
  likeStatus: { type: String, enum: ['none', 'liked', 'superliked', 'passed'], default: 'none' },
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

// Export models
module.exports = {
  Moment: mongoose.model('Moment', MomentSchema),
  Note: mongoose.model('Note', NoteSchema),
  Circle: mongoose.model('Circle', CircleSchema),
  CirclePost: mongoose.model('CirclePost', CirclePostSchema),
  Story: mongoose.model('Story', StorySchema),
  Date: mongoose.model('Date', DateSchema),
  Spotlight: mongoose.model('Spotlight', SpotlightSchema),
  Roam: mongoose.model('Roam', RoamSchema),
  Match: mongoose.model('Match', MatchSchema),
};
