const mongoose = require('mongoose');

const locationChatSchema = new mongoose.Schema({
    locationName: {
        type: String,
        required: true,
        index: true
    },
    messages: [{
        userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        text: String,
        createdAt: { type: Date, default: Date.now }
    }],
    createdAt: {
        type: Date,
        default: Date.now,
        expires: '24h' // Chat expires after 24 hours
    }
});

module.exports = mongoose.model('LocationChat', locationChatSchema);
