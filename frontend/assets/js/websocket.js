// MEENGLE - WebSocket Real-Time Chat Client
// Handles real-time messaging, typing indicators, and user status

class WebSocketClient {
  constructor(serverUrl = 'http://localhost:3001') {
    this.serverUrl = serverUrl;
    this.socket = null;
    this.connected = false;
    this.userId = null;
    this.listeners = {};
  }

  // Connect to WebSocket server
  connect(userId) {
    this.userId = userId;
    const wsUrl = this.serverUrl.replace('http', 'ws');
    
    this.socket = io(this.serverUrl, {
      auth: {
        token: localStorage.getItem('authToken')
      }
    });

    this.socket.on('connect', () => {
      console.log('? WebSocket connected');
      this.connected = true;
      this.emit('user-online', { userId });
      this.emit('connection', { status: 'connected' });
    });

    this.socket.on('disconnect', () => {
      console.log('? WebSocket disconnected');
      this.connected = false;
      this.emit('connection', { status: 'disconnected' });
    });

    this.socket.on('error', (error) => {
      console.error('WebSocket error:', error);
      this.emit('error', { error });
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

    this.socket.on('user-status-changed', (data) => {
      this.emit('user-status-changed', data);
    });
  }

  // Join chat room
  joinChat(matchId) {
    if (!this.connected) {
      console.error('WebSocket not connected');
      return;
    }
    this.socket.emit('join-chat', {
      userId: this.userId,
      matchId
    });
  }

  // Send message
  sendMessage(matchId, message) {
    if (!this.connected) {
      console.error('WebSocket not connected');
      return;
    }
    this.socket.emit('send-message', {
      userId: this.userId,
      matchId,
      message
    });
  }

  // Send typing indicator
  sendTyping(matchId) {
    if (!this.connected) return;
    this.socket.emit('typing', {
      userId: this.userId,
      matchId
    });
  }

  // Stop typing indicator
  stopTyping(matchId) {
    if (!this.connected) return;
    this.socket.emit('stop-typing', {
      userId: this.userId,
      matchId
    });
  }

  // Event management
  on(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event].push(callback);
  }

  off(event, callback) {
    if (!this.listeners[event]) return;
    this.listeners[event] = this.listeners[event].filter(cb => cb !== callback);
  }

  emit(event, data) {
    if (!this.listeners[event]) return;
    this.listeners[event].forEach(callback => {
      try {
        callback(data);
      } catch (error) {
        console.error(`Error in ${event} listener:`, error);
      }
    });
  }

  // Disconnect
  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.connected = false;
    }
  }

  // Check connection status
  isConnected() {
    return this.connected;
  }
}

// Create global instance
window.webSocketClient = new WebSocketClient();

// Export for use in modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = WebSocketClient;
}
