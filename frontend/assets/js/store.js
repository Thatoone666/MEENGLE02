// Simple State Management System for Meengle
class Store {
  constructor(initialState = {}) {
    this.state = initialState;
    this.listeners = [];
    this.subscriptions = {};
  }

  setState(newState) {
    this.state = { ...this.state, ...newState };
    this.notifyListeners();
  }

  getState() {
    return { ...this.state };
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter(l => l !== listener);
    };
  }

  notifyListeners() {
    this.listeners.forEach(listener => listener(this.state));
  }

  // Specific subscription for parts of state
  watch(key, callback) {
    const unsubscribe = this.subscribe(state => {
      callback(state[key]);
    });
    return unsubscribe;
  }

  // Async actions
  async dispatch(action, payload) {
    try {
      const result = await action(this, payload);
      return result;
    } catch (error) {
      console.error('Dispatch error:', error);
      throw error;
    }
  }
}

// Create app-wide store with initial state
const appStore = new Store({
  user: null,
  isAuthenticated: false,
  authToken: localStorage.getItem('authToken'),
  matches: [],
  currentMatch: null,
  messages: [],
  notifications: [],
  moments: [],
  loading: false,
  error: null,
  toast: null,
  userStatus: {},
  typingUsers: {},
  unreadCount: 0,
});

// Auth actions
const authActions = {
  async login(store, { email, password }) {
    store.setState({ loading: true, error: null });
    try {
      const response = await window.apiClient.login(email, password);
      store.setState({
        user: response.user,
        isAuthenticated: true,
        authToken: response.token,
        loading: false,
      });
      localStorage.setItem('authToken', response.token);
      return response;
    } catch (error) {
      store.setState({ 
        error: error.message, 
        loading: false,
        isAuthenticated: false 
      });
      throw error;
    }
  },

  async logout(store) {
    await window.apiClient.logout();
    store.setState({
      user: null,
      isAuthenticated: false,
      authToken: null,
      matches: [],
      messages: [],
      notifications: [],
    });
    localStorage.removeItem('authToken');
  },

  async signup(store, { email, password, name }) {
    store.setState({ loading: true, error: null });
    try {
      const response = await window.apiClient.signup(email, password, name);
      store.setState({
        user: response.user,
        isAuthenticated: true,
        authToken: response.token,
        loading: false,
      });
      localStorage.setItem('authToken', response.token);
      return response;
    } catch (error) {
      store.setState({ 
        error: error.message, 
        loading: false 
      });
      throw error;
    }
  },

  async loadProfile(store) {
    store.setState({ loading: true });
    try {
      const user = await window.apiClient.getProfile();
      store.setState({ user, loading: false });
      return user;
    } catch (error) {
      store.setState({ error: error.message, loading: false });
      throw error;
    }
  },

  async updateProfile(store, profileData) {
    store.setState({ loading: true, error: null });
    try {
      const user = await window.apiClient.updateProfile(profileData);
      store.setState({ user, loading: false });
      return user;
    } catch (error) {
      store.setState({ error: error.message, loading: false });
      throw error;
    }
  },
};

// Matching actions
const matchingActions = {
  async loadMatches(store) {
    store.setState({ loading: true });
    try {
      const matches = await window.apiClient.getMatches();
      store.setState({ matches, loading: false });
      return matches;
    } catch (error) {
      store.setState({ error: error.message, loading: false });
      throw error;
    }
  },

  async loadPotentialMatches(store) {
    store.setState({ loading: true });
    try {
      const potentialMatches = await window.apiClient.getPotentialMatches();
      store.setState({ loading: false });
      return potentialMatches;
    } catch (error) {
      store.setState({ error: error.message, loading: false });
      throw error;
    }
  },

  async likeUser(store, targetUserId) {
    try {
      const result = await window.apiClient.likeUser(targetUserId);
      if (result.mutualMatch) {
        store.setState({ 
          toast: { message: "It's a match!", type: 'success' }
        });
      }
      return result;
    } catch (error) {
      store.setState({ error: error.message });
      throw error;
    }
  },

  async passUser(store, targetUserId) {
    try {
      return await window.apiClient.passUser(targetUserId);
    } catch (error) {
      store.setState({ error: error.message });
      throw error;
    }
  },

  async getMatchCount(store) {
    try {
      const { count } = await window.apiClient.getMatchCount();
      return count;
    } catch (error) {
      console.error('Error fetching match count:', error);
      return 0;
    }
  },
};

// Chat actions
const chatActions = {
  setCurrentMatch(store, match) {
    store.setState({ currentMatch: match, messages: [] });
  },

  async loadConversation(store, matchId) {
    store.setState({ loading: true });
    try {
      const messages = await window.apiClient.getConversation(matchId);
      store.setState({ messages, loading: false });
      return messages;
    } catch (error) {
      store.setState({ error: error.message, loading: false });
      throw error;
    }
  },

  async sendMessage(store, { matchId, message }) {
    try {
      const result = await window.apiClient.sendMessage(matchId, message);
      const current = store.getState();
      store.setState({
        messages: [...current.messages, {
          id: Math.random(),
          message,
          timestamp: new Date(),
          userId: current.user?.id,
          read: false,
        }],
      });
      return result;
    } catch (error) {
      store.setState({ error: error.message });
      throw error;
    }
  },

  addMessage(store, message) {
    const current = store.getState();
    store.setState({
      messages: [...current.messages, message],
    });
  },

  setTypingUser(store, { userId, isTyping }) {
    const current = store.getState();
    const typingUsers = { ...current.typingUsers };
    if (isTyping) {
      typingUsers[userId] = true;
    } else {
      delete typingUsers[userId];
    }
    store.setState({ typingUsers });
  },
};

// Notification actions
const notificationActions = {
  async loadNotifications(store) {
    try {
      const notifications = await window.apiClient.getNotifications();
      store.setState({ notifications });
      return notifications;
    } catch (error) {
      console.error('Error loading notifications:', error);
      return [];
    }
  },

  async markAsRead(store, notificationId) {
    try {
      await window.apiClient.markNotificationAsRead(notificationId);
      const current = store.getState();
      const notifications = current.notifications.map(n =>
        n.id === notificationId ? { ...n, read: true } : n
      );
      store.setState({ notifications });
    } catch (error) {
      console.error('Error marking notification as read:', error);
    }
  },

  addNotification(store, notification) {
    const current = store.getState();
    store.setState({
      notifications: [notification, ...current.notifications],
      unreadCount: current.unreadCount + 1,
    });
  },

  setUnreadCount(store, count) {
    store.setState({ unreadCount: count });
  },
};

// Toast actions
const toastActions = {
  showToast(store, { message, type = 'info', duration = 3000 }) {
    store.setState({ toast: { message, type } });
    setTimeout(() => {
      store.setState({ toast: null });
    }, duration);
  },

  success(store, message) {
    toastActions.showToast(store, { message, type: 'success' });
  },

  error(store, message) {
    toastActions.showToast(store, { message, type: 'error' });
  },

  info(store, message) {
    toastActions.showToast(store, { message, type: 'info' });
  },

  warning(store, message) {
    toastActions.showToast(store, { message, type: 'warning' });
  },
};

// Combine all actions
const actions = {
  ...authActions,
  ...matchingActions,
  ...chatActions,
  ...notificationActions,
  ...toastActions,
};

// Export everything globally
window.appStore = appStore;
window.authActions = authActions;
window.matchingActions = matchingActions;
window.chatActions = chatActions;
window.notificationActions = notificationActions;
window.toastActions = toastActions;

// Helper to dispatch actions
window.dispatch = (actionGroup, actionName, payload) => {
  const action = actionGroup[actionName];
  if (action) {
    return appStore.dispatch(action, payload);
  }
  console.error(`Action ${actionName} not found in action group`);
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { appStore, actions };
}
