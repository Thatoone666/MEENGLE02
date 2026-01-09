const mongoose = require('mongoose');

const roamSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
    unique: true,
  },
  isActive: {
    type: Boolean,
    default: false,
  },
  destination: String,
  startDate: Date,
  endDate: Date,
  enabledAt: {
    type: Date,
    default: Date.now,
  },
});

const localGuideSchema = new mongoose.Schema({
  name: String,
  rating: {
    type: Number,
    min: 0,
    max: 5,
  },
  specialties: [String],
  city: String,
  reviews: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

const localEventSchema = new mongoose.Schema({
  name: String,
  location: String,
  category: String,
  date: Date,
  capacity: Number,
  attending: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = {
  Roam: mongoose.model('Roam', roamSchema),
  LocalGuide: mongoose.model('LocalGuide', localGuideSchema),
  LocalEvent: mongoose.model('LocalEvent', localEventSchema),
};
