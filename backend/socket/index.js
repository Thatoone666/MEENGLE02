const Message = require('../models/Message');
const { Moment, Note, Story, Match } = require('../models/featureModels');
const analytics = require('../lib/analytics');
const metrics = require('../lib/metrics');
const fcmService = require('../lib/fcm_service');
const User = require('../models/User');

let onlineUsers = {};
let userSockets = {}; // Map userId to socketId
let userFCMTokens = {}; // Map userId to FCM token

const configureSocket = (io) => {
    io.on('connection', (socket) => {
        console.log('Socket connected:', socket.id);

        socket.on('authenticate', (userId) => {
            userSockets[userId] = socket.id;
            onlineUsers[userId] = true;
            io.emit('onlineStatus', onlineUsers);
            socket.join(`user:${userId}`);
            console.log(`User ${userId} authenticated`);
        });

        socket.on('registerFCMToken', async (data) => {
            const { userId, fcmToken } = data;
            userFCMTokens[userId] = fcmToken;
            // Save to database for persistence
            try {
                await User.findByIdAndUpdate(userId, { fcmToken: fcmToken });
            } catch (e) {
                console.error('Error saving FCM token:', e);
            }
        });

        socket.on('userOnline', (userId) => {
            onlineUsers[userId] = true;
            userSockets[userId] = socket.id;
            socket.join(`user:${userId}`);
            io.emit('onlineStatus', onlineUsers);
        });

        socket.on('disconnect', () => {
            // Find and remove user from tracking
            for (const [userId, socketId] of Object.entries(userSockets)) {
                if (socketId === socket.id) {
                    delete onlineUsers[userId];
                    delete userSockets[userId];
                    io.emit('onlineStatus', onlineUsers);
                    console.log(`User ${userId} disconnected`);
                    break;
                }
            }
        });

        socket.on('join', async ({ userId, matchId }) => {
            const room = [userId, matchId].sort().join('-');
            socket.join(room);
            
            const history = await Message.find({
                $or: [
                    { from: userId, to: matchId },
                    { from: matchId, to: userId }
                ]
            }).populate('replyTo').sort('timestamp');
            
            socket.emit('history', history);
        });

        socket.on('message', async ({ from, to, text, replyTo }) => {
            const room = [from, to].sort().join('-');
            const msg = new Message({ from, to, text, replyTo });
            await msg.save();
            
            const populatedMsg = await Message.findById(msg._id).populate('replyTo');
            io.to(room).emit('message', populatedMsg.toObject());
            
            // Send FCM notification if recipient not online
            if (!onlineUsers[to] && userFCMTokens[to]) {
                await fcmService.notifyNewMessage(to, userFCMTokens[to], {
                    senderId: from,
                    senderName: 'Someone',
                    messageText: text,
                    matchId: room,
                });
            }
            
            analytics.capture(from, 'message_sent', { to, textLength: (text || '').length });
            metrics.incMessage();
        });

        socket.on('typing', ({ from, to }) => {
            const room = [from, to].sort().join('-');
            socket.to(room).emit('typing', { from });
        });

        socket.on('read', async ({ from, to }) => {
            const room = [from, to].sort().join('-');
            await Message.updateMany({ from: to, to: from, read: false }, { $set: { read: true } });
            socket.to(room).emit('read', { from });
        });

        // --- REAL-TIME FEATURE EVENTS ---
        
        // Moments: Notify users when moment is extended
        socket.on('moment:extended', async (data) => {
            const { momentId, fromUserId, toUserId } = data;
            const moment = await Moment.findById(momentId);
            if (moment) {
                const targetSocket = userSockets[toUserId];
                if (targetSocket) {
                    io.to(`user:${toUserId}`).emit('moment:notification', {
                        type: 'extended',
                        moment: moment.toObject(),
                        timestamp: new Date()
                    });
                }
            }
        });

        // Notes: Notify when note is liked
        socket.on('note:liked', async (data) => {
            const { noteId, fromUserId, toUserId } = data;
            const note = await Note.findById(noteId);
            if (note) {
                io.to(`user:${note.toUserId}`).emit('note:notification', {
                    type: 'liked',
                    note: note.toObject(),
                    likedBy: fromUserId,
                    timestamp: new Date()
                });
            }
        });

        // Stories: Notify when story is viewed
        socket.on('story:viewed', async (data) => {
            const { storyId, viewedByUserId } = data;
            const story = await Story.findById(storyId);
            if (story) {
                io.to(`user:${story.userId}`).emit('story:notification', {
                    type: 'viewed',
                    storyId: storyId,
                    viewedBy: viewedByUserId,
                    viewCount: story.viewCount,
                    timestamp: new Date()
                });

                // Send FCM notification if user not online
                if (!onlineUsers[story.userId] && userFCMTokens[story.userId]) {
                    await fcmService.notifyStoryView(story.userId, userFCMTokens[story.userId], {
                        storyId: storyId,
                        viewedBy: viewedByUserId,
                        viewerName: 'Someone'
                    });
                }
            }
        });

        // Stories: Notify when story is liked
        socket.on('story:liked', async (data) => {
            const { storyId, likedByUserId } = data;
            const story = await Story.findById(storyId);
            if (story) {
                // Increment like count
                story.likeCount = (story.likeCount || 0) + 1;
                if (!story.likedByUserIds) story.likedByUserIds = [];
                if (!story.likedByUserIds.includes(likedByUserId)) {
                    story.likedByUserIds.push(likedByUserId);
                }
                await story.save();

                // Notify story owner
                io.to(`user:${story.userId}`).emit('story:notification', {
                    type: 'liked',
                    storyId: storyId,
                    likedBy: likedByUserId,
                    likeCount: story.likeCount,
                    timestamp: new Date()
                });

                // Send FCM notification if user not online
                if (!onlineUsers[story.userId] && userFCMTokens[story.userId]) {
                    await fcmService.notifyStoryLike(story.userId, userFCMTokens[story.userId], {
                        storyId: storyId,
                        likedBy: likedByUserId,
                        likerName: 'Someone'
                    });
                }
            }
        });

        // Matches: Notify when user receives like
        socket.on('match:liked', async (data) => {
            const { user1Id, user2Id } = data;
            // Notify user2 that user1 liked them
            io.to(`user:${user2Id}`).emit('match:notification', {
                type: 'liked',
                fromUserId: user1Id,
                timestamp: new Date()
            });

            // Send FCM notification
            if (userFCMTokens[user2Id]) {
                await fcmService.notifyNewMatch(user2Id, userFCMTokens[user2Id], {
                    matchId: [user1Id, user2Id].sort().join('-'),
                    matchUserId: user1Id,
                    matchName: 'Someone'
                });
            }
        });

        // Matches: Mutual match notification (both liked each other)
        socket.on('match:mutual', async (data) => {
            const { user1Id, user2Id } = data;
            io.to(`user:${user1Id}`).emit('match:notification', {
                type: 'mutual',
                matchedWith: user2Id,
                timestamp: new Date()
            });
            io.to(`user:${user2Id}`).emit('match:notification', {
                type: 'mutual',
                matchedWith: user1Id,
                timestamp: new Date()
            });

            // Send FCM notifications
            if (userFCMTokens[user1Id]) {
                await fcmService.notifyNewMatch(user1Id, userFCMTokens[user1Id], {
                    matchId: [user1Id, user2Id].sort().join('-'),
                    matchUserId: user2Id,
                    matchName: 'Someone'
                });
            }
            if (userFCMTokens[user2Id]) {
                await fcmService.notifyNewMatch(user2Id, userFCMTokens[user2Id], {
                    matchId: [user1Id, user2Id].sort().join('-'),
                    matchUserId: user1Id,
                    matchName: 'Someone'
                });
            }
        });

        // --- SOCKET.IO SIGNALING FOR VIDEO CALLS ---
        socket.on('videoOffer', ({ to, offer }) => {
            const room = [socket.id, to].sort().join('-'); // Simplified room for signaling
            io.to(to).emit('videoOffer', { from: socket.id, offer });
        });

        socket.on('videoAnswer', ({ to, answer }) => {
            io.to(to).emit('videoAnswer', { from: socket.id, answer });
        });

        socket.on('iceCandidate', ({ to, candidate }) => {
            io.to(to).emit('iceCandidate', { from: socket.id, candidate });
        });
    });
};

module.exports = configureSocket;
