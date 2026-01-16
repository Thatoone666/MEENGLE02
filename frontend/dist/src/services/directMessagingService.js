/**
 * Direct Messaging Service
 * Enables Flame+ tier users to send direct messages to profiles
 */

class DirectMessagingService {
  constructor() {
    this.messageTypes = [
      'text',
      'image',
      'emoji',
      'voice',
      'video_call_request',
      'activity_invite',
    ];

    this.messageStatus = ['sent', 'delivered', 'read'];
  }

  /**
   * Send direct message to user
   */
  async sendMessage(recipientId, messageData) {
    try {
      const response = await fetch('/api/v1/messages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          recipientId,
          content: messageData.content,
          type: messageData.type || 'text',
          context: messageData.context, // 'profile', 'swipe', 'check_in', 'activity'
          attachments: messageData.attachments || [],
          isForwarded: messageData.isForwarded || false,
        }),
      });

      if (!response.ok) throw new Error('Failed to send message');
      return await response.json();
    } catch (error) {
      console.error('Error sending message:', error);
      throw error;
    }
  }

  /**
   * Get conversation with user
   */
  async getConversation(userId, limit = 50, offset = 0) {
    try {
      const response = await fetch(
        `/api/v1/messages/conversations/${userId}?limit=${limit}&offset=${offset}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching conversation:', error);
      return [];
    }
  }

  /**
   * Get all conversations
   */
  async getConversations(limit = 20, offset = 0) {
    try {
      const response = await fetch(
        `/api/v1/messages/conversations?limit=${limit}&offset=${offset}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching conversations:', error);
      return [];
    }
  }

  /**
   * Mark message as read
   */
  async markAsRead(messageId) {
    try {
      const response = await fetch(`/api/v1/messages/${messageId}/read`, {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to mark as read');
      return await response.json();
    } catch (error) {
      console.error('Error marking message as read:', error);
      throw error;
    }
  }

  /**
   * Mark conversation as read
   */
  async markConversationAsRead(userId) {
    try {
      const response = await fetch(
        `/api/v1/messages/conversations/${userId}/read`,
        {
          method: 'PUT',
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) throw new Error('Failed to mark conversation as read');
      return await response.json();
    } catch (error) {
      console.error('Error marking conversation as read:', error);
      throw error;
    }
  }

  /**
   * Delete message
   */
  async deleteMessage(messageId) {
    try {
      const response = await fetch(`/api/v1/messages/${messageId}`, {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to delete message');
      return await response.json();
    } catch (error) {
      console.error('Error deleting message:', error);
      throw error;
    }
  }

  /**
   * Unsend message (delete within time limit)
   */
  async unsendMessage(messageId) {
    try {
      const response = await fetch(`/api/v1/messages/${messageId}/unsend`, {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to unsend message');
      return await response.json();
    } catch (error) {
      console.error('Error unsending message:', error);
      throw error;
    }
  }

  /**
   * Block user
   */
  async blockUser(userId) {
    try {
      const response = await fetch(`/api/v1/users/${userId}/block`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to block user');
      return await response.json();
    } catch (error) {
      console.error('Error blocking user:', error);
      throw error;
    }
  }

  /**
   * Unblock user
   */
  async unblockUser(userId) {
    try {
      const response = await fetch(`/api/v1/users/${userId}/unblock`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to unblock user');
      return await response.json();
    } catch (error) {
      console.error('Error unblocking user:', error);
      throw error;
    }
  }

  /**
   * Report user
   */
  async reportUser(userId, reason, description) {
    try {
      const response = await fetch(`/api/v1/users/${userId}/report`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          reason,
          description,
          timestamp: new Date().toISOString(),
        }),
      });

      if (!response.ok) throw new Error('Failed to report user');
      return await response.json();
    } catch (error) {
      console.error('Error reporting user:', error);
      throw error;
    }
  }

  /**
   * Request video call
   */
  async requestVideoCall(recipientId) {
    try {
      const response = await fetch('/api/v1/video-calls', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          recipientId,
          type: 'video_request',
        }),
      });

      if (!response.ok) throw new Error('Failed to request video call');
      return await response.json();
    } catch (error) {
      console.error('Error requesting video call:', error);
      throw error;
    }
  }

  /**
   * Accept video call
   */
  async acceptVideoCall(callId) {
    try {
      const response = await fetch(`/api/v1/video-calls/${callId}/accept`, {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to accept video call');
      return await response.json();
    } catch (error) {
      console.error('Error accepting video call:', error);
      throw error;
    }
  }

  /**
   * Decline video call
   */
  async declineVideoCall(callId) {
    try {
      const response = await fetch(`/api/v1/video-calls/${callId}/decline`, {
        method: 'PUT',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to decline video call');
      return await response.json();
    } catch (error) {
      console.error('Error declining video call:', error);
      throw error;
    }
  }

  /**
   * Invite to activity
   */
  async inviteToActivity(recipientId, activityId) {
    try {
      const response = await fetch('/api/v1/activity-invites', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          recipientId,
          activityId,
        }),
      });

      if (!response.ok) throw new Error('Failed to invite to activity');
      return await response.json();
    } catch (error) {
      console.error('Error inviting to activity:', error);
      throw error;
    }
  }

  /**
   * Get message statistics
   */
  async getMessageStats() {
    try {
      const response = await fetch('/api/v1/messages/stats', {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) return null;
      return await response.json();
    } catch (error) {
      console.error('Error fetching message stats:', error);
      return null;
    }
  }

  /**
   * Search conversations
   */
  async searchConversations(query) {
    try {
      const response = await fetch(`/api/v1/messages/search?q=${query}`, {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error searching conversations:', error);
      return [];
    }
  }

  /**
   * Get auth token
   */
  getAuthToken() {
    return localStorage.getItem('authToken') || '';
  }

  /**
   * Check if user can message (tier check)
   */
  canSendDirectMessage(userTier) {
    const allowedTiers = ['flame', 'wildfire'];
    return allowedTiers.includes(userTier);
  }

  /**
   * Format message timestamp
   */
  formatMessageTime(timestamp) {
    const now = new Date();
    const messageDate = new Date(timestamp);
    const diffMs = now - messageDate;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;

    return messageDate.toLocaleDateString();
  }
}

export default new DirectMessagingService();
