import express from 'express';
import { verifyToken } from './auth.js';
import mongoose from 'mongoose';

const router = express.Router();

const mediaSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  filename: String,
  originalSize: Number,
  compressedSize: Number,
  url: String,
  thumbnailUrl: String,
  type: { type: String, enum: ['image', 'video'] },
  width: Number,
  height: Number,
  duration: Number,
  uploadedAt: { type: Date, default: Date.now }
});

mediaSchema.index({ userId: 1, uploadedAt: -1 });

let Media;
try {
  Media = mongoose.model('Media', mediaSchema);
} catch {
  Media = mongoose.model('Media');
}

router.post('/upload', verifyToken, async (req, res) => {
  try {
    const { filename, url, type, size, width, height, duration, thumbnailUrl } = req.body;

    if (!filename || !url || !type) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const MAX_FILE_SIZE = 50 * 1024 * 1024;
    if (size > MAX_FILE_SIZE) {
      return res.status(413).json({ error: 'File too large (max 50MB)' });
    }

    const estimatedCompressedSize = Math.floor(size * 0.6);

    const userId = new mongoose.Types.ObjectId(req.userId);
    const media = new Media({
      userId,
      filename,
      originalSize: size,
      compressedSize: estimatedCompressedSize,
      url,
      thumbnailUrl,
      type,
      width,
      height,
      duration
    });

    await media.save();

    res.json({
      success: true,
      media: {
        id: media._id,
        filename: media.filename,
        originalSize: media.originalSize,
        compressedSize: media.compressedSize,
        url: media.url,
        thumbnailUrl: media.thumbnailUrl,
        type: media.type,
        uploadedAt: media.uploadedAt
      }
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: 'Failed to upload media' });
  }
});

router.get('/my-files', verifyToken, async (req, res) => {
  try {
    const userId = new mongoose.Types.ObjectId(req.userId);
    const limit = Math.min(parseInt(req.query.limit) || 50, 200);
    const skip = parseInt(req.query.skip) || 0;

    const media = await Media.find({ userId })
      .sort({ uploadedAt: -1 })
      .limit(limit)
      .skip(skip)
      .lean();

    const total = await Media.countDocuments({ userId });

    res.json({ media, total, limit, skip });
  } catch (error) {
    console.error('Get media error:', error);
    res.status(500).json({ error: 'Failed to fetch files' });
  }
});

router.delete('/:mediaId', verifyToken, async (req, res) => {
  try {
    const { mediaId } = req.params;
    const userId = new mongoose.Types.ObjectId(req.userId);

    if (!mongoose.Types.ObjectId.isValid(mediaId)) {
      return res.status(400).json({ error: 'Invalid media ID' });
    }

    const media = await Media.findById(mediaId);

    if (!media || media.userId.toString() !== userId.toString()) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    await Media.deleteOne({ _id: mediaId });

    res.json({ success: true });
  } catch (error) {
    console.error('Delete media error:', error);
    res.status(500).json({ error: 'Failed to delete media' });
  }
});

export default router;
