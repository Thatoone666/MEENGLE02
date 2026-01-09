const admin = require('firebase-admin');
const logger = require('../config/logger');

class PushNotificationService {
  constructor() {
    try {
      if (!admin.apps.length) {
        const serviceAccount = JSON.parse(
          process.env.FIREBASE_SERVICE_ACCOUNT || '{}'
        );
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
        });
      }
      this.messaging = admin.messaging();
      logger.info('Firebase Cloud Messaging initialized');
    } catch (error) {
      logger.warn('Firebase initialization failed', { 
        error: error.message 
      });
    }
  }

  /**
   * Send notification to a device
   */
  async sendToDevice(deviceToken, notification, data = {}) {
    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data,
        token: deviceToken,
      };

      const response = await this.messaging.send(message);
      logger.info('Notification sent to device', { 
        deviceToken, 
        messageId: response 
      });
      return response;
    } catch (error) {
      logger.error('Failed to send notification', { 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Send notification to multiple devices
   */
  async sendToMultipleDevices(deviceTokens, notification, data = {}) {
    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data,
        tokens: deviceTokens,
      };

      const response = await this.messaging.sendMulticast(message);
      logger.info('Notifications sent to multiple devices', { 
        successCount: response.successCount,
        failureCount: response.failureCount,
      });
      return response;
    } catch (error) {
      logger.error('Failed to send multicast notification', { 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Send notification to a topic
   */
  async sendToTopic(topic, notification, data = {}) {
    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data,
        topic,
      };

      const response = await this.messaging.send(message);
      logger.info('Notification sent to topic', { 
        topic, 
        messageId: response 
      });
      return response;
    } catch (error) {
      logger.error('Failed to send topic notification', { 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Subscribe device to topic
   */
  async subscribeToTopic(deviceTokens, topic) {
    try {
      const response = await this.messaging.subscribeToTopic(
        deviceTokens,
        topic
      );
      logger.info('Devices subscribed to topic', { 
        topic, 
        count: deviceTokens.length 
      });
      return response;
    } catch (error) {
      logger.error('Failed to subscribe to topic', { 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Unsubscribe device from topic
   */
  async unsubscribeFromTopic(deviceTokens, topic) {
    try {
      const response = await this.messaging.unsubscribeFromTopic(
        deviceTokens,
        topic
      );
      logger.info('Devices unsubscribed from topic', { 
        topic, 
        count: deviceTokens.length 
      });
      return response;
    } catch (error) {
      logger.error('Failed to unsubscribe from topic', { 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Send data message
   */
  async sendDataMessage(deviceToken, data = {}) {
    try {
      const message = {
        data,
        token: deviceToken,
      };

      const response = await this.messaging.send(message);
      logger.info('Data message sent', { 
        deviceToken, 
        messageId: response 
      });
      return response;
    } catch (error) {
      logger.error('Failed to send data message', { 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Send broadcast notification
   */
  async sendBroadcast(notification, data = {}, topic = 'broadcast') {
    try {
      return await this.sendToTopic(topic, notification, data);
    } catch (error) {
      logger.error('Failed to send broadcast', { 
        error: error.message 
      });
      throw error;
    }
  }
}

module.exports = new PushNotificationService();
