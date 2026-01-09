const mongoose = require('mongoose');

const dateBookingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },
  dateId: String,
  status: {
    type: String,
    enum: ['booked', 'completed', 'cancelled'],
    default: 'booked',
  },
  bookedFor: Date,
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('DateBooking', dateBookingSchema);
