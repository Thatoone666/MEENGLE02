// Advanced Notification System
class NotificationManager {
  constructor(options = {}) {
    this.apiClient = window.apiClient;
    this.store = window.appStore;
    this.notifications = [];
    this.unreadCount = 0;
    this.pollInterval = options.pollInterval || 30000; // 30 seconds
    this.allowPushNotifications = options.allowPushNotifications !== false;

    this.init();
  }

  async init() {
    await this.requestPermissions();
    await this.loadNotifications();
    this.startPolling();
    this.setupEventListeners();
  }

  async requestPermissions() {
    if ('Notification' in window && Notification.permission === 'default') {
      await Notification.requestPermission();
    }
  }

  async loadNotifications() {
    try {
      const response = await this.apiClient.getNotifications(20);
      this.notifications = response.notifications || [];
      this.unreadCount = this.notifications.filter(n => !n.read).length;
      this.store.setState({ 
        notifications: this.notifications,
        unreadCount: this.unreadCount
      });
    } catch (error) {
      console.error('Failed to load notifications:', error);
    }
  }

  startPolling() {
    this.pollInterval = setInterval(() => this.loadNotifications(), this.pollInterval);
  }

  stopPolling() {
    if (this.pollInterval) clearInterval(this.pollInterval);
  }

  async markAsRead(notificationId) {
    try {
      await this.apiClient.markNotificationAsRead(notificationId);
      
      const notif = this.notifications.find(n => n.id === notificationId);
      if (notif) notif.read = true;
      
      this.unreadCount = this.notifications.filter(n => !n.read).length;
      this.store.setState({ 
        notifications: this.notifications,
        unreadCount: this.unreadCount
      });
    } catch (error) {
      console.error('Failed to mark notification as read:', error);
    }
  }

  async markAllAsRead() {
    try {
      await Promise.all(
        this.notifications
          .filter(n => !n.read)
          .map(n => this.markAsRead(n.id))
      );
    } catch (error) {
      console.error('Failed to mark all notifications as read:', error);
    }
  }

  async deleteNotification(notificationId) {
    try {
      // API call would go here
      this.notifications = this.notifications.filter(n => n.id !== notificationId);
      this.store.setState({ notifications: this.notifications });
    } catch (error) {
      console.error('Failed to delete notification:', error);
    }
  }

  async deleteAllNotifications() {
    try {
      // API call would go here
      this.notifications = [];
      this.unreadCount = 0;
      this.store.setState({ 
        notifications: [],
        unreadCount: 0
      });
    } catch (error) {
      console.error('Failed to delete all notifications:', error);
    }
  }

  sendPushNotification(title, options = {}) {
    if (!this.allowPushNotifications || !('Notification' in window)) return;

    if (Notification.permission === 'granted') {
      new Notification(title, {
        icon: '/assets/icon.png',
        tag: options.tag || 'notification',
        badge: '/assets/badge.png',
        ...options
      });
    }
  }

  setupEventListeners() {
    // Listen for new notifications via Socket.IO
    if (window.realtimeClient) {
      window.realtimeClient.on('notification', (data) => {
        this.addNotification(data);
      });
    }
  }

  addNotification(notification) {
    this.notifications.unshift(notification);
    this.unreadCount++;
    
    this.store.setState({ 
      notifications: this.notifications,
      unreadCount: this.unreadCount
    });

    this.sendPushNotification(notification.title, {
      body: notification.message,
      tag: notification.id
    });
  }

  getNotifications() {
    return this.notifications;
  }

  getUnreadCount() {
    return this.unreadCount;
  }
}

// Notification Bell Component
class NotificationBell {
  constructor(options = {}) {
    this.container = options.container;
    this.manager = options.manager;
    this.store = window.appStore;
    
    this.store.watch('unreadCount', (count) => this.updateBadge(count));
    this.render();
    this.setupEventListeners();
  }

  render() {
    if (!this.container) return;

    const count = this.store.getState().unreadCount;

    this.container.innerHTML = `
      <button class="notification-bell" title="Notifications">
        ??
        ${count > 0 ? `<span class="notification-badge">${Math.min(count, 99)}${count > 99 ? '+' : ''}</span>` : ''}
      </button>
    `;

    this.setupEventListeners();
  }

  updateBadge(count) {
    const badge = this.container?.querySelector('.notification-badge');
    if (badge) {
      if (count > 0) {
        badge.textContent = `${Math.min(count, 99)}${count > 99 ? '+' : ''}`;
        badge.style.display = 'block';
      } else {
        badge.style.display = 'none';
      }
    }
  }

  setupEventListeners() {
    const bell = this.container?.querySelector('.notification-bell');
    if (bell) {
      bell.addEventListener('click', () => this.openPanel());
    }
  }

  openPanel() {
    new NotificationPanel({ manager: this.manager }).show();
  }

  injectStyles() {
    if (document.getElementById('notification-bell-styles')) return;

    const styles = `
      .notification-bell {
        position: relative;
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        padding: 0.5rem;
        transition: transform 0.3s;
      }

      .notification-bell:hover {
        transform: scale(1.1);
      }

      .notification-badge {
        position: absolute;
        top: 0;
        right: 0;
        background: #ff4444;
        color: white;
        border-radius: 50%;
        width: 20px;
        height: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.75rem;
        font-weight: bold;
      }
    `;

    const style = document.createElement('style');
    style.id = 'notification-bell-styles';
    style.textContent = styles;
    document.head.appendChild(style);
  }
}

// Notification Panel Component
class NotificationPanel {
  constructor(options = {}) {
    this.manager = options.manager;
    this.store = window.appStore;
  }

  show() {
    const modal = new window.Modal({
      title: 'Notifications',
      content: this.renderContent(),
      className: 'modal-notifications'
    });

    modal.open();
  }

  renderContent() {
    const notifications = this.store.getState().notifications || [];

    if (notifications.length === 0) {
      return '<p class="empty-state">No notifications</p>';
    }

    return `
      <div class="notifications-list">
        <button class="btn btn-sm btn-secondary" onclick="window.notificationManager.markAllAsRead()">
          Mark all as read
        </button>
        ${notifications.map(notif => this.renderNotification(notif)).join('')}
        <button class="btn btn-sm btn-danger" onclick="window.notificationManager.deleteAllNotifications()">
          Clear all
        </button>
      </div>
    `;
  }

  renderNotification(notif) {
    return `
      <div class="notification-item ${notif.read ? 'read' : 'unread'}">
        <div class="notification-content">
          <h4>${notif.title || 'Notification'}</h4>
          <p>${notif.message}</p>
          <span class="notification-time">${window.Utils.formatTime(notif.createdAt)}</span>
        </div>
        <div class="notification-actions">
          ${!notif.read ? `
            <button class="icon-btn" onclick="window.notificationManager.markAsRead('${notif.id}')" title="Mark as read">
              ?
            </button>
          ` : ''}
          <button class="icon-btn" onclick="window.notificationManager.deleteNotification('${notif.id}')" title="Delete">
            ?
          </button>
        </div>
      </div>
    `;
  }
}

// Notification Types
const NotificationType = {
  MATCH: 'match',           // New match
  MESSAGE: 'message',       // New message
  LIKE: 'like',             // Someone liked you
  COMMENT: 'comment',       // Comment on your post
  FOLLOW: 'follow',         // Someone followed you
  PROMOTION: 'promotion',   // Promo/offer
  SYSTEM: 'system'          // System notification
};

// Notification Factory
class NotificationFactory {
  static createMatch(userId, userName) {
    return {
      type: NotificationType.MATCH,
      title: "It's a Match! ??",
      message: `You matched with ${userName}`,
      link: `/pages/chat.html?match=${userId}`,
      icon: '??',
      priority: 'high'
    };
  }

  static createMessage(userId, userName, preview) {
    return {
      type: NotificationType.MESSAGE,
      title: 'New Message',
      message: `${userName}: ${preview}`,
      link: `/pages/chat.html?match=${userId}`,
      icon: '??',
      priority: 'high'
    };
  }

  static createLike(userId, userName) {
    return {
      type: NotificationType.LIKE,
      title: 'Someone Liked You ??',
      message: `${userName} liked your profile`,
      link: `/pages/profile-details.html?user=${userId}`,
      icon: '??',
      priority: 'medium'
    };
  }

  static createComment(postId, userName, commentText) {
    return {
      type: NotificationType.COMMENT,
      title: 'New Comment',
      message: `${userName} commented: ${commentText}`,
      link: `/pages/moments.html?post=${postId}`,
      icon: '??',
      priority: 'medium'
    };
  }

  static createPromotion(title, description, code) {
    return {
      type: NotificationType.PROMOTION,
      title,
      message: description,
      code,
      icon: '??',
      priority: 'low'
    };
  }

  static createSystem(title, message) {
    return {
      type: NotificationType.SYSTEM,
      title,
      message,
      icon: '??',
      priority: 'low'
    };
  }
}

// Initialize notification system
window.NotificationManager = NotificationManager;
window.NotificationBell = NotificationBell;
window.NotificationPanel = NotificationPanel;
window.NotificationType = NotificationType;
window.NotificationFactory = NotificationFactory;
window.notificationManager = new NotificationManager();

export { NotificationManager, NotificationBell, NotificationPanel, NotificationType, NotificationFactory };
