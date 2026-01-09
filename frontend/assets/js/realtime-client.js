// Socket.IO Real-Time Chat Client
class RealtimeClient {
  constructor(serverURL = process.env.SOCKET_URL || 'http://localhost:3001') {
    this.socket = null;
    this.serverURL = serverURL;
    this.userId = null;
    this.listeners = {};
    this.currentRoom = null;
  }

  connect(userId, token) {
    this.userId = userId;
    
    this.socket = io(this.serverURL, {
      auth: {
        token: token,
      },
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      reconnectionAttempts: 5,
    });

    this.setupEventListeners();
    return this;
  }

  setupEventListeners() {
    this.socket.on('connect', () => {
      console.log('Socket connected:', this.socket.id);
      this.emit('socket-connected', { socketId: this.socket.id });
      this.goOnline();
    });

    this.socket.on('disconnect', () => {
      console.log('Socket disconnected');
      this.emit('socket-disconnected');
    });

    this.socket.on('user-status-changed', (data) => {
      this.emit('user-status-changed', data);
    });

    this.socket.on('user-joined', (data) => {
      this.emit('user-joined', data);
    });

    this.socket.on('receive-message', (data) => {
      this.emit('message-received', data);
    });

    this.socket.on('user-typing', (data) => {
      this.emit('user-typing', data);
    });

    this.socket.on('user-stop-typing', (data) => {
      this.emit('user-stop-typing', data);
    });

    this.socket.on('message-error', (data) => {
      this.emit('message-error', data);
    });

    this.socket.on('error', (error) => {
      console.error('Socket error:', error);
      this.emit('socket-error', error);
    });
  }

  on(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event].push(callback);
  }

  off(event, callback) {
    if (this.listeners[event]) {
      this.listeners[event] = this.listeners[event].filter(cb => cb !== callback);
    }
  }

  emit(event, data) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(callback => callback(data));
    }
  }

  goOnline() {
    if (this.socket) {
      this.socket.emit('user-online', { userId: this.userId });
    }
  }

  joinChatRoom(matchId) {
    if (!this.socket) {
      console.error('Socket not connected');
      return;
    }

    this.currentRoom = matchId;
    this.socket.emit('join-chat', {
      userId: this.userId,
      matchId: matchId,
    });
  }

  leaveChatRoom() {
    if (this.socket && this.currentRoom) {
      this.socket.emit('leave-chat', {
        userId: this.userId,
        matchId: this.currentRoom,
      });
      this.currentRoom = null;
    }
  }

  sendMessage(matchId, message) {
    if (!this.socket) {
      console.error('Socket not connected');
      return;
    }

    this.socket.emit('send-message', {
      userId: this.userId,
      matchId: matchId,
      message: message,
    });
  }

  startTyping(matchId) {
    if (this.socket) {
      this.socket.emit('typing', {
        userId: this.userId,
        matchId: matchId,
      });
    }
  }

  stopTyping(matchId) {
    if (this.socket) {
      this.socket.emit('stop-typing', {
        userId: this.userId,
        matchId: matchId,
      });
    }
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }

  isConnected() {
    return this.socket && this.socket.connected;
  }

  getSocketId() {
    return this.socket ? this.socket.id : null;
  }
}

// Export and make available globally
if (typeof module !== 'undefined' && module.exports) {
  module.exports = RealtimeClient;
}

window.RealtimeClient = RealtimeClient;
window.realtimeClient = null;

// Helper function to initialize realtime client
window.initRealtimeClient = (userId, token) => {
  window.realtimeClient = new RealtimeClient();
  window.realtimeClient.connect(userId, token);
  return window.realtimeClient;
};
