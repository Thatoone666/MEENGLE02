// Meengle API Client - Core HTTP client for all frontend requests
class APIClient {
  constructor(baseURL = process.env.API_URL || 'http://localhost:3001') {
    this.baseURL = baseURL;
    this.token = localStorage.getItem('authToken');
  }

  setToken(token) {
    this.token = token;
    localStorage.setItem('authToken', token);
  }

  getToken() {
    return this.token || localStorage.getItem('authToken');
  }

  async request(endpoint, options = {}) {
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers,
    };

    if (this.getToken()) {
      headers['Authorization'] = `Bearer ${this.getToken()}`;
    }

    const response = await fetch(`${this.baseURL}${endpoint}`, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      localStorage.removeItem('authToken');
      window.location.href = '/pages/login.html';
    }

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Request failed');
    }

    return data;
  }

  // Auth endpoints
  async signup(email, password, name) {
    return this.request('/api/auth/signup', {
      method: 'POST',
      body: JSON.stringify({ email, password, name }),
    });
  }

  async login(email, password) {
    const data = await this.request('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    if (data.token) {
      this.setToken(data.token);
    }
    return data;
  }

  async logout() {
    localStorage.removeItem('authToken');
    this.token = null;
  }

  async getProfile() {
    return this.request('/api/auth/me');
  }

  async updateProfile(profileData) {
    return this.request('/api/auth/profile', {
      method: 'POST',
      body: JSON.stringify(profileData),
    });
  }

  async changePassword(oldPassword, newPassword) {
    return this.request('/api/auth/change-password', {
      method: 'POST',
      body: JSON.stringify({ oldPassword, newPassword }),
    });
  }

  async deleteAccount(password) {
    return this.request('/api/auth/delete-account', {
      method: 'POST',
      body: JSON.stringify({ password }),
    });
  }

  // Matching endpoints
  async getPotentialMatches() {
    return this.request('/api/matches/potential');
  }

  async likeUser(targetUserId) {
    return this.request('/api/matches/like', {
      method: 'POST',
      body: JSON.stringify({ targetUserId }),
    });
  }

  async passUser(targetUserId) {
    return this.request('/api/matches/pass', {
      method: 'POST',
      body: JSON.stringify({ targetUserId }),
    });
  }

  async getMatches() {
    return this.request('/api/matches/matches');
  }

  async getMatchCount() {
    return this.request('/api/matches/count');
  }

  // Chat endpoints
  async sendMessage(matchId, message) {
    return this.request('/api/chat/message', {
      method: 'POST',
      body: JSON.stringify({ matchId, message }),
    });
  }

  async getConversation(matchId, limit = 50, skip = 0) {
    return this.request(`/api/chat/${matchId}?limit=${limit}&skip=${skip}`);
  }

  async getConversations(limit = 20, skip = 0) {
    return this.request(`/api/chat/conversations?limit=${limit}&skip=${skip}`);
  }

  async markMessagesAsRead(matchId) {
    return this.request('/api/chat/read', {
      method: 'POST',
      body: JSON.stringify({ matchId }),
    });
  }

  // Media endpoints
  async uploadMedia(filename, url, type, size, metadata = {}) {
    return this.request('/api/media/upload', {
      method: 'POST',
      body: JSON.stringify({
        filename,
        url,
        type,
        size,
        ...metadata,
      }),
    });
  }

  async getMyFiles(limit = 50, skip = 0) {
    return this.request(`/api/media/my-files?limit=${limit}&skip=${skip}`);
  }

  async deleteMedia(mediaId) {
    return this.request(`/api/media/${mediaId}`, {
      method: 'DELETE',
    });
  }

  // Moments endpoints
  async createMoment(content, photos = []) {
    return this.request('/api/moments/create', {
      method: 'POST',
      body: JSON.stringify({ content, photos }),
    });
  }

  async getMoments(userId, limit = 20, skip = 0) {
    return this.request(`/api/moments/${userId}?limit=${limit}&skip=${skip}`);
  }

  async likeMoment(momentId) {
    return this.request(`/api/moments/${momentId}/like`, {
      method: 'POST',
    });
  }

  async commentOnMoment(momentId, content) {
    return this.request(`/api/moments/${momentId}/comment`, {
      method: 'POST',
      body: JSON.stringify({ content }),
    });
  }

  // Discovery endpoints
  async getDiscovery(filters = {}) {
    const queryString = new URLSearchParams(filters).toString();
    return this.request(`/api/discovery?${queryString}`);
  }

  async getTrendingMoments() {
    return this.request('/api/discovery/trending');
  }

  // Notifications endpoints
  async getNotifications(limit = 20, skip = 0) {
    return this.request(`/api/notifications?limit=${limit}&skip=${skip}`);
  }

  async markNotificationAsRead(notificationId) {
    return this.request(`/api/notifications/${notificationId}/read`, {
      method: 'POST',
    });
  }

  async getNotificationCount() {
    return this.request('/api/notifications/count');
  }

  // Boosts endpoints
  async getBoosters() {
    return this.request('/api/boosts/boosters');
  }

  async boostProfile() {
    return this.request('/api/boosts/boost', {
      method: 'POST',
    });
  }

  // Payment endpoints
  async createPaymentIntent(amount, currency = 'USD') {
    return this.request('/api/payments/create-intent', {
      method: 'POST',
      body: JSON.stringify({ amount, currency }),
    });
  }

  async verifyPayment(paymentId) {
    return this.request('/api/payments/verify', {
      method: 'POST',
      body: JSON.stringify({ paymentId }),
    });
  }

  // Health check
  async healthCheck() {
    return this.request('/health');
  }

  // Test endpoint
  async test() {
    return this.request('/api/test');
  }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = APIClient;
}

// Make available globally
window.APIClient = APIClient;
window.apiClient = new APIClient();
