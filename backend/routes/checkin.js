const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const CheckIn = require('../models/CheckIn');
const User = require('../models/User');

// @route   POST api/checkin
// @desc    Check in to a location
// @access  Private
router.post('/', auth, async (req, res) => {
    const { locationName, vibe } = req.body;
    if (!locationName) {
        return res.status(400).json({ msg: 'Location name is required' });
    }

    try {
        // Atomically find and update or create a new check-in for the user
        const checkIn = await CheckIn.findOneAndUpdate(
            { userId: req.user.id },
            { locationName: locationName, vibe: vibe, createdAt: new Date() },
            { new: true, upsert: true }
        );
        res.json(checkIn);
    } catch (err) {
        err.status = 500;
        err.message = err.message || 'Server Error';
        next(err);
    }
});

// @route   GET api/checkin/:locationName
// @desc    Get users checked in at a specific location
// @access  Private
router.get('/:locationName', auth, async (req, res) => {
    try {
        const locationName = decodeURIComponent(req.params.locationName);
        
        const checkIns = await CheckIn.find({ 
            locationName: locationName,
            userId: { $ne: req.user.id } // Exclude the current user
        }).populate('userId', 'username profile.age profile.photos bio');

        const users = checkIns.map(ci => ci.userId);
        
        res.json(users);
    } catch (err) {
        err.status = 500;
        err.message = err.message || 'Server Error';
        next(err);
    }
});

// @route   DELETE api/checkin
// @desc    Check out from current location
// @access  Private
router.delete('/', auth, async (req, res) => {
    try {
        await CheckIn.findOneAndDelete({ userId: req.user.id });
        res.json({ msg: 'Checked out successfully' });
    } catch (err) {
        err.status = 500;
        err.message = err.message || 'Server Error';
        next(err);
    }
});

module.exports = router;
