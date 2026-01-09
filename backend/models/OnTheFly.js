const mongoose = require('mongoose');

const onTheFlySchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    activity: {
        type: String,
        required: true,
        trim: true,
        maxlength: 140
    },
    location: {
        type: String,
        trim: true,
        maxlength: 100
    },
    createdAt: {
        type: Date,
        default: Date.now,
        expires: '6h' // Automatically delete after 6 hours
    }
});

module.exports = mongoose.model('OnTheFly', onTheFlySchema);
