const authRoutes = require('./auth');
const profileRoutes = require('./profile');
const matchesRoutes = require('./matches');
const ontheflyRoutes = require('./onthefly');
const checkinRoutes = require('./checkin');
const locationChatRoutes = require('./locationchat');
const usersRoutes = require('./users');
const paymentRoutes = require('./payment');
const fraudRoutes = require('./fraud');
const promptRoutes = require('./prompts');
const verifyRoutes = require('./verify');
const metricsRoutes = require('./moments');
const notesRoutes = require('./notes');
const circlesRoutes = require('./circles');
const storiesRoutes = require('./stories');
const datesRoutes = require('./dates');
const spotlightRoutes = require('./spotlight');
const roamRoutes = require('./roam');
const discoveryRoutes = require('./discovery');
const mediaRoutes = require('./media');
const notificationsRoutes = require('./notifications');
const metrics = require('../lib/metrics');

const configureRoutes = (app, io) => {
    // Initialize payment routes with Socket.io
    if (paymentRoutes.setIO) {
        paymentRoutes.setIO(io);
    }

    app.use('/api/auth', authRoutes);
    app.use('/api/profile', profileRoutes);
    app.use('/api/matches', matchesRoutes);
    app.use('/api/onthefly', ontheflyRoutes);
    app.use('/api/checkin', checkinRoutes);
    app.use('/api/locationchat', locationChatRoutes);
    app.use('/api/users', usersRoutes);
    app.use('/api/payment', paymentRoutes);
    app.use('/api/fraud', fraudRoutes);
    app.use('/api/prompts', promptRoutes);
    app.use('/api/verify', verifyRoutes);
    app.use('/api/moments', metricsRoutes);
    app.use('/api/notes', notesRoutes);
    app.use('/api/circles', circlesRoutes);
    app.use('/api/stories', storiesRoutes);
    app.use('/api/dates', datesRoutes);
    app.use('/api/spotlight', spotlightRoutes);
    app.use('/api/roam', roamRoutes);
    app.use('/api/discovery', discoveryRoutes);
    app.use('/api/media', mediaRoutes);
    app.use('/api/notifications', notificationsRoutes);

    // Expose minimal config for frontend initialization
    app.get('/config', (req, res) => {
        res.json({
            sentryDsn: process.env.SENTRY_DSN || null,
            posthog: process.env.POSTHOG_API_KEY ? { host: process.env.POSTHOG_HOST || 'https://app.posthog.com', key: process.env.POSTHOG_API_KEY } : null
        });
    });

    // Metrics endpoint
    app.get('/metrics', async (req, res) => {
        try {
            res.set('Content-Type', metrics.register.contentType);
            res.end(await metrics.register.metrics());
        } catch (e) {
            res.status(500).end(e.message);
        }
    });
};

module.exports = configureRoutes;
