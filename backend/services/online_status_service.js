// Backend: Online Status Service
// File: backend/services/online_status_service.js

import { EventEmitter } from 'events';

class OnlineStatusService extends EventEmitter {
  constructor() {
    super();
    this.onlineUsers = new Map(); // userId -> { socketId, connectedAt, status }
    this.userSockets = new Map(); // socketId -> userId
  }

  /**
   * Track user coming online
   */
  userConnected(userId, socketId, userData) {
    const now = new Date();
    
    this.onlineUsers.set(userId, {
      socketId,
      connectedAt: now,
      lastActivity: now,
      status: 'online',
      userData: userData
    });
    
    this.userSockets.set(socketId, userId);
    
    this.emit('user-online', {
      userId,
      timestamp: now,
      status: 'online'
    });
  }

  /**
   * Track user going offline
   */
  userDisconnected(socketId) {
    const userId = this.userSockets.get(socketId);
    
    if (userId && this.onlineUsers.has(userId)) {
      const userData = this.onlineUsers.get(userId);
      const now = new Date();
      
      this.onlineUsers.delete(userId);
      this.userSockets.delete(socketId);
      
      this.emit('user-offline', {
        userId,
        lastSeen: now,
        status: 'offline'
      });
    }
  }

  /**
   * Update user activity (prevents idle timeout)
   */
  updateActivity(socketId) {
    const userId = this.userSockets.get(socketId);
    
    if (userId && this.onlineUsers.has(userId)) {
      const userData = this.onlineUsers.get(userId);
      userData.lastActivity = new Date();
      userData.status = 'online'; // Reset from idle
      
      this.onlineUsers.set(userId, userData);
    }
  }

  /**
   * Mark user as idle (inactive for 5 minutes)
   */
  markIdle(socketId) {
    const userId = this.userSockets.get(socketId);
    
    if (userId && this.onlineUsers.has(userId)) {
      const userData = this.onlineUsers.get(userId);
      userData.status = 'idle';
      
      this.onlineUsers.set(userId, userData);
      
      this.emit('user-idle', {
        userId,
        timestamp: new Date(),
        status: 'idle'
      });
    }
  }

  /**
   * Get online status for user
   */
  getStatus(userId) {
    const data = this.onlineUsers.get(userId);
    
    if (data) {
      return {
        isOnline: true,
        status: data.status,
        connectedAt: data.connectedAt,
        lastActivity: data.lastActivity
      };
    }
    
    return {
      isOnline: false,
      status: 'offline',
      lastSeen: null
    };
  }

  /**
   * Get multiple users' statuses
   */
  getStatusMultiple(userIds) {
    const statuses = {};
    
    userIds.forEach(userId => {
      statuses[userId] = this.getStatus(userId);
    });
    
    return statuses;
  }

  /**
   * Get all online users
   */
  getOnlineUsers() {
    const users = [];
    
    this.onlineUsers.forEach((data, userId) => {
      users.push({
        userId,
        status: data.status,
        connectedAt: data.connectedAt,
        lastActivity: data.lastActivity
      });
    });
    
    return users;
  }

  /**
   * Get count of online users
   */
  getOnlineCount() {
    return this.onlineUsers.size;
  }

  /**
   * Check if user is online
   */
  isOnline(userId) {
    return this.onlineUsers.has(userId);
  }
}

export default new OnlineStatusService();
