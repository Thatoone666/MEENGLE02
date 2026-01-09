import cron from 'node-cron';
import { createBackup, deleteOldBackups } from './backupService.js';
import { logger } from './monitoringService.js';

export const initScheduledTasks = () => {
  // Backup every 24 hours at 2 AM
  cron.schedule('0 2 * * *', async () => {
    try {
      logger.info('Starting scheduled backup...');
      const result = await createBackup();
      logger.info('Backup completed', result);
      
      await deleteOldBackups(30);
      logger.info('Old backups cleaned');
    } catch (error) {
      logger.error('Scheduled backup failed', { error: error.message });
    }
  });

  // Clean suspicious accounts daily at 3 AM
  cron.schedule('0 3 * * *', async () => {
    try {
      logger.info('Starting suspicious account cleanup...');
      const SuspiciousAccount = require('mongoose').model('SuspiciousAccount');
      const result = await SuspiciousAccount.deleteMany({
        reviewed: true,
        reviewedAt: { $lt: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000) }
      });
      logger.info('Suspicious accounts cleaned', { deleted: result.deletedCount });
    } catch (error) {
      logger.error('Suspicious account cleanup failed', { error: error.message });
    }
  });

  // Check for expired subscriptions daily at 4 AM
  cron.schedule('0 4 * * *', async () => {
    try {
      logger.info('Starting subscription expiration check...');
      const Subscription = require('mongoose').model('Subscription');
      const result = await Subscription.updateMany(
        { status: 'active', renewalDate: { $lt: new Date() } },
        { status: 'expired' }
      );
      logger.info('Expired subscriptions marked', { updated: result.modifiedCount });
    } catch (error) {
      logger.error('Subscription check failed', { error: error.message });
    }
  });

  logger.info('Scheduled tasks initialized');
};

export default initScheduledTasks;
