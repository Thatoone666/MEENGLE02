const mongoose = require('mongoose');
const logger = require('./logger');

const connectDB = async () => {
    try {
        const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/meengle';
        
        // Helper to mask credentials when printing the URI to logs
        function maskMongoUri(uri) {
            try {
                const withoutProto = uri.replace(/^mongodb(?:\+srv)?:\/\//, '');
                if (withoutProto.indexOf('@') !== -1) {
                    return uri.replace(/:\/\/(.*@)/, '://<redacted>@');
                }
                return uri;
            } catch (e) { return '<invalid-uri>'; }
        }

        const isLocal = mongoUri.startsWith('mongodb://localhost') || mongoUri.indexOf('127.0.0.1') !== -1;
        logger.info(`Attempting MongoDB connection (${isLocal ? 'local' : 'remote'}) - ${maskMongoUri(mongoUri)}`);

        await mongoose.connect(mongoUri, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });

    } catch (err) {
        logger.error('Initial MongoDB connection error', { message: err.message || String(err) });
        if (process.env.NODE_ENV === 'production') {
            process.exit(1);
        }
    }
};

mongoose.connection.on('connected', () => {
    logger.info('Mongoose connected to MongoDB');
});

mongoose.connection.on('error', (err) => {
    logger.error('Mongoose connection error', { error: err.message || String(err) });
});

mongoose.connection.on('disconnected', () => {
    logger.warn('Mongoose disconnected from MongoDB');
});

module.exports = connectDB;
