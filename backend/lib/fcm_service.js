const admin = require('firebase-admin');

class FCMService {
  constructor() {
    this.messaging = admin.messaging();
  }

  /**
   * Send notification to specific user via FCM token
   */
  async sendToUser(fcmToken, notification) {
    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        token: fcmToken,
      };

      const response = await this.messaging.send(message);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('Error sending FCM message:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send notification to topic (broadcast)
   */
  async sendToTopic(topic, notification) {
    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        topic: topic,
      };

      const response = await this.messaging.send(message);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('Error sending FCM topic message:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send multicast notification to multiple users
   */
  async sendToMultipleUsers(fcmTokens, notification) {
    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
      };

      const response = await this.messaging.sendMulticast({
        ...message,
        tokens: fcmTokens,
      });

      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
      };
    } catch (error) {
      console.error('Error sending multicast FCM message:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Send story view notification
   */
  async notifyStoryView(userId, fcmToken, storyData) {
    const notification = {
      title: '👁️ Your story was viewed!',
      body: `${storyData.viewerName || 'Someone'} viewed your story`,
      data: {
        type: 'story_viewed',
        storyId: storyData.storyId,
        viewedBy: storyData.viewedBy,
        action: 'open_story',
      },
    };

    return this.sendToUser(fcmToken, notification);
  }

  /**
   * Send story like notification
   */
  async notifyStoryLike(userId, fcmToken, storyData) {
    const notification = {
      title: '❤️ Your story got liked!',
      body: `${storyData.likerName || 'Someone'} liked your story`,
      data: {
        type: 'story_liked',
        storyId: storyData.storyId,
        likedBy: storyData.likedBy,
        action: 'open_story',
      },
    };

    return this.sendToUser(fcmToken, notification);
  }

  /**
   * Send new message notification
   */
  async notifyNewMessage(userId, fcmToken, messageData) {
    const notification = {
      title: `💬 ${messageData.senderName || 'New message'}`,
      body: messageData.messageText,
      data: {
        type: 'new_message',
        senderId: messageData.senderId,
        matchId: messageData.matchId,
        action: 'open_chat',
      },
    };

    return this.sendToUser(fcmToken, notification);
  }

  /**
   * Send new match notification
   */
  async notifyNewMatch(userId, fcmToken, matchData) {
    const notification = {
      title: '💕 New match!',
      body: `You matched with ${matchData.matchName || 'someone'}`,
      data: {
        type: 'new_match',
        matchId: matchData.matchId,
        matchUserId: matchData.matchUserId,
        action: 'open_matches',
      },
    };

    return this.sendToUser(fcmToken, notification);
  }

  /**
   * Send payment notification
   */
  async notifyPaymentConfirmed(userId, fcmToken, paymentData) {
    const notification = {
      title: '💳 Payment Confirmed',
      body: `Your ${paymentData.tier} Spotlight is now active!`,
      data: {
        type: 'payment_confirmed',
        tier: paymentData.tier,
        expiresAt: paymentData.expiresAt,
        action: 'open_spotlight',
      },
    };

    return this.sendToUser(fcmToken, notification);
  }

  /**
   * Send reminder notification
   */
  async sendReminder(userId, fcmToken, reminderData) {
    const notification = {
      title: reminderData.title,
      body: reminderData.body,
      data: {
        type: 'reminder',
        ...reminderData.data,
      },
    };

    return this.sendToUser(fcmToken, notification);
  }

  /**
   * Subscribe user to topic
   */
  async subscribeToTopic(fcmTokens, topic) {
    try {
      await this.messaging.subscribeToTopic(fcmTokens, topic);
      return { success: true };
    } catch (error) {
      console.error('Error subscribing to topic:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Unsubscribe user from topic
   */
  async unsubscribeFromTopic(fcmTokens, topic) {
    try {
      await this.messaging.unsubscribeFromTopic(fcmTokens, topic);
      return { success: true };
    } catch (error) {
      console.error('Error unsubscribing from topic:', error);
      return { success: false, error: error.message };
    }
  }
}

module.exports = new FCMService();
