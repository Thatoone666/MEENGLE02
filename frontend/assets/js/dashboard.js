// Dashboard - Main user interface after login
class Dashboard {
  constructor() {
    this.apiClient = window.apiClient;
    this.realtimeClient = window.realtimeClient;
    this.store = window.appStore;
    this.currentTab = 'discover';
    this.init();
  }

  async init() {
    this.setupEventListeners();
    await this.loadInitialData();
    this.render();
  }

  setupEventListeners() {
    document.addEventListener('click', (e) => {
      if (e.target.matches('[data-tab]')) {
        this.switchTab(e.target.dataset.tab);
      }
      
      if (e.target.matches('[data-action]')) {
        this.handleAction(e.target.dataset.action, e.target.dataset.id);
      }
    });

    if (this.realtimeClient && this.realtimeClient.isConnected()) {
      this.realtimeClient.on('user-status-changed', (data) => this.handleStatusChange(data));
      this.realtimeClient.on('message-received', (data) => this.handleNewMessage(data));
    }
  }

  async loadInitialData() {
    try {
      this.store.setState({ loading: true });
      
      const user = await this.apiClient.getProfile();
      this.store.setState({ user, loading: false });
      
      await this.loadMatches();
      await this.loadNotifications();
    } catch (error) {
      console.error('Failed to load dashboard:', error);
      this.store.setState({ error: error.message, loading: false });
    }
  }

  async loadMatches() {
    try {
      const matches = await this.apiClient.getMatches();
      this.store.setState({ matches });
    } catch (error) {
      console.error('Failed to load matches:', error);
    }
  }

  async loadNotifications() {
    try {
      const notifications = await this.apiClient.getNotifications(10);
      this.store.setState({ notifications });
    } catch (error) {
      console.error('Failed to load notifications:', error);
    }
  }

  switchTab(tab) {
    this.currentTab = tab;
    this.render();
  }

  async handleAction(action, id) {
    switch (action) {
      case 'open-chat':
        this.openChat(id);
        break;
      case 'like-user':
        await this.likeUser(id);
        break;
      case 'pass-user':
        await this.passUser(id);
        break;
      case 'view-profile':
        this.viewProfile(id);
        break;
      case 'logout':
        await this.logout();
        break;
    }
  }

  async likeUser(userId) {
    try {
      const result = await this.apiClient.likeUser(userId);
      if (result.mutualMatch) {
        window.Utils.showToast("It's a match! ??", 5000, 'success');
        await this.loadMatches();
      } else {
        window.Utils.showToast('Like sent!', 2000, 'info');
      }
      this.render();
    } catch (error) {
      window.Utils.showToast('Failed to like user', 3000, 'error');
    }
  }

  async passUser(userId) {
    try {
      await this.apiClient.passUser(userId);
      window.Utils.showToast('Passed', 1500, 'info');
      this.render();
    } catch (error) {
      window.Utils.showToast('Failed to pass user', 3000, 'error');
    }
  }

  openChat(matchId) {
    window.location.href = `/pages/chat.html?match=${matchId}`;
  }

  viewProfile(userId) {
    window.location.href = `/pages/profile-details.html?user=${userId}`;
  }

  handleStatusChange(data) {
    const { userId, status } = data;
    this.store.setState({
      userStatus: { ...this.store.getState().userStatus, [userId]: status }
    });
    this.render();
  }

  handleNewMessage(data) {
    const current = this.store.getState();
    this.store.setState({
      unreadCount: current.unreadCount + 1
    });
    window.Utils.showNotification('New Message', {
      body: data.message.substring(0, 50),
      icon: '/assets/icon.png'
    });
  }

  async logout() {
    if (confirm('Are you sure you want to logout?')) {
      await this.store.dispatch(window.authActions.logout, {});
      window.location.href = '/pages/login.html';
    }
  }

  render() {
    const state = this.store.getState();
    const container = document.getElementById('app');
    
    if (!container) return;

    let html = this.renderHeader(state);
    
    switch (this.currentTab) {
      case 'discover':
        html += this.renderDiscoverTab(state);
        break;
      case 'matches':
        html += this.renderMatchesTab(state);
        break;
      case 'messages':
        html += this.renderMessagesTab(state);
        break;
      case 'notifications':
        html += this.renderNotificationsTab(state);
        break;
      case 'profile':
        html += this.renderProfileTab(state);
        break;
    }

    container.innerHTML = html;
  }

  renderHeader(state) {
    return `
      <header class="dashboard-header">
        <div class="header-content">
          <h1>Meengle</h1>
          <div class="header-actions">
            <button class="icon-btn" title="Messages">
              <span class="notification-badge">${state.unreadCount}</span>
              ??
            </button>
            <button class="icon-btn" title="Settings" data-tab="profile">??</button>
            <button class="icon-btn" title="Logout" data-action="logout">??</button>
          </div>
        </div>
        <nav class="tabs">
          <button class="tab ${this.currentTab === 'discover' ? 'active' : ''}" data-tab="discover">
            Discover
          </button>
          <button class="tab ${this.currentTab === 'matches' ? 'active' : ''}" data-tab="matches">
            Matches (${state.matches.length})
          </button>
          <button class="tab ${this.currentTab === 'messages' ? 'active' : ''}" data-tab="messages">
            Messages
          </button>
          <button class="tab ${this.currentTab === 'notifications' ? 'active' : ''}" data-tab="notifications">
            Notifications
          </button>
        </nav>
      </header>
    `;
  }

  renderDiscoverTab(state) {
    if (state.loading) {
      return '<div class="loading">Loading matches...</div>';
    }

    if (!state.matches || state.matches.length === 0) {
      return '<div class="empty-state">No matches available. Check back soon!</div>';
    }

    return `
      <section class="discover-section">
        <div class="match-cards">
          ${state.matches.map(match => `
            <div class="match-card">
              <div class="card-image">
                <img src="${match.photos?.[0] || '/assets/default-avatar.png'}" alt="${match.name}">
              </div>
              <div class="card-info">
                <h3>${match.name}, ${match.age || '?'}</h3>
                <p class="card-bio">${match.bio || 'No bio'}</p>
                <p class="card-location">?? ${match.location?.city || 'Unknown'}</p>
              </div>
              <div class="card-actions">
                <button class="btn btn-secondary" data-action="pass-user" data-id="${match._id}">
                  Pass
                </button>
                <button class="btn btn-primary" data-action="like-user" data-id="${match._id}">
                  Like ??
                </button>
              </div>
            </div>
          `).join('')}
        </div>
      </section>
    `;
  }

  renderMatchesTab(state) {
    if (state.matches.length === 0) {
      return '<div class="empty-state">You have no matches yet. Like some users!</div>';
    }

    return `
      <section class="matches-section">
        <div class="matches-grid">
          ${state.matches.map(match => `
            <div class="match-item" data-id="${match._id}">
              <div class="match-thumbnail">
                <img src="${match.photos?.[0] || '/assets/default-avatar.png'}" alt="${match.name}">
                <span class="match-status ${state.userStatus?.[match._id] === 'online' ? 'online' : 'offline'}"></span>
              </div>
              <div class="match-details">
                <h4>${match.name}, ${match.age || '?'}</h4>
                <button class="btn btn-small" data-action="open-chat" data-id="${match._id}">
                  Chat
                </button>
              </div>
            </div>
          `).join('')}
        </div>
      </section>
    `;
  }

  renderMessagesTab(state) {
    if (!state.matches || state.matches.length === 0) {
      return '<div class="empty-state">No messages yet.</div>';
    }

    return `
      <section class="messages-section">
        <div class="conversations-list">
          ${state.matches.map(match => `
            <div class="conversation-item" data-action="open-chat" data-id="${match._id}">
              <img src="${match.photos?.[0] || '/assets/default-avatar.png'}" alt="${match.name}">
              <div class="conversation-info">
                <h4>${match.name}</h4>
                <p class="last-message">Tap to open chat...</p>
              </div>
            </div>
          `).join('')}
        </div>
      </section>
    `;
  }

  renderNotificationsTab(state) {
    if (!state.notifications || state.notifications.length === 0) {
      return '<div class="empty-state">No notifications.</div>';
    }

    return `
      <section class="notifications-section">
        <div class="notifications-list">
          ${state.notifications.map(notif => `
            <div class="notification-item">
              <h4>${notif.title || 'Notification'}</h4>
              <p>${notif.message}</p>
              <span class="time">${window.Utils.formatTime(notif.createdAt)}</span>
            </div>
          `).join('')}
        </div>
      </section>
    `;
  }

  renderProfileTab(state) {
    return `
      <section class="profile-section">
        <div class="profile-card">
          <img src="${state.user?.photos?.[0] || '/assets/default-avatar.png'}" alt="Profile">
          <h2>${state.user?.name || 'User'}</h2>
          <p>${state.user?.bio || 'No bio'}</p>
          <button class="btn btn-primary" onclick="window.location.href='/pages/profile-details.html'">
            Edit Profile
          </button>
          <button class="btn btn-secondary" onclick="window.location.href='/pages/settings.html'">
            Settings
          </button>
        </div>
      </section>
    `;
  }
}

// Initialize dashboard when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  if (window.apiClient && window.appStore.getState().isAuthenticated) {
    new Dashboard();
  } else {
    window.location.href = '/pages/login.html';
  }
});

export { Dashboard };
