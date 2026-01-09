const mongoose = require('mongoose');

const checkInSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    locationName: {
        type: String,
        required: true,
        trim: true,
        index: true // Index for faster queries on location
    },
    vibe: {
        type: String,
        trim: true,
        maxlength: 100
    },
    createdAt: {
        type: Date,
        default: Date.now,
        expires: '24h' // Automatically remove check-ins after 24 hours
    }
});

// Ensure a user can only be checked into one place at a time
checkInSchema.index({ userId: 1 }, { unique: true });

module.exports = mongoose.model('CheckIn', checkInSchema);
