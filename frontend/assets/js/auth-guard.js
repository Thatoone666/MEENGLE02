// Authentication Guard - Route protection and auth management
class AuthGuard {
  static async checkAuth() {
    const token = localStorage.getItem('authToken');
    
    if (!token) {
      return null;
    }

    try {
      const user = await window.apiClient.getProfile();
      window.appStore.setState({
        isAuthenticated: true,
        user,
        authToken: token
      });
      return user;
    } catch (error) {
      localStorage.removeItem('authToken');
      return null;
    }
  }

  static async require() {
    const user = await this.checkAuth();
    
    if (!user) {
      window.location.href = '/pages/login.html';
      return null;
    }

    return user;
  }

  static isAuthenticated() {
    return !!localStorage.getItem('authToken');
  }

  static getToken() {
    return localStorage.getItem('authToken');
  }

  static setToken(token) {
    localStorage.setItem('authToken', token);
  }

  static logout() {
    localStorage.removeItem('authToken');
    window.appStore.setState({
      isAuthenticated: false,
      user: null,
      authToken: null
    });
    window.location.href = '/pages/login.html';
  }
}

// Route Guard - Protect routes based on authentication
class RouteGuard {
  static defineRoutes(routes) {
    this.routes = routes;
    this.setupRouting();
  }

  static setupRouting() {
    window.addEventListener('DOMContentLoaded', () => {
      this.checkCurrentRoute();
    });

    // Handle navigation
    document.addEventListener('click', (e) => {
      const link = e.target.closest('[data-route]');
      if (link) {
        e.preventDefault();
        const route = link.dataset.route;
        this.navigate(route);
      }
    });
  }

  static async checkCurrentRoute() {
    const path = window.location.pathname;
    const route = Object.values(this.routes).find(r => r.path === path);

    if (!route) {
      return;
    }

    if (route.requiresAuth) {
      const user = await AuthGuard.require();
      if (!user) return;
    }

    if (route.onEnter) {
      route.onEnter();
    }
  }

  static navigate(routePath) {
    const route = this.routes[routePath];

    if (!route) {
      console.error(`Route not found: ${routePath}`);
      return;
    }

    if (route.requiresAuth && !AuthGuard.isAuthenticated()) {
      window.location.href = '/pages/login.html';
      return;
    }

    window.location.href = route.path;
  }
}

// Session Management
class SessionManager {
  static init(options = {}) {
    this.warningTime = options.warningTime || 15 * 60 * 1000; // 15 minutes
    this.expiryTime = options.expiryTime || 30 * 60 * 1000; // 30 minutes
    this.lastActivity = Date.now();

    this.setupActivityTracking();
    this.setupWarning();
  }

  static setupActivityTracking() {
    ['mousedown', 'keydown', 'scroll', 'touchstart'].forEach(event => {
      document.addEventListener(event, () => {
        this.lastActivity = Date.now();
      }, true);
    });
  }

  static setupWarning() {
    setInterval(() => {
      const timeSinceActivity = Date.now() - this.lastActivity;

      if (timeSinceActivity >= this.expiryTime) {
        this.handleExpiration();
      } else if (timeSinceActivity >= this.warningTime) {
        this.showWarning();
      }
    }, 60000); // Check every minute
  }

  static showWarning() {
    if (this.warningShown) return;

    this.warningShown = true;

    new window.Modal({
      title: 'Session Expiring',
      content: 'Your session will expire soon due to inactivity. Click OK to continue.',
      buttons: [
        {
          label: 'Logout',
          type: 'secondary',
          action: 'logout',
          onClick: () => AuthGuard.logout()
        },
        {
          label: 'Continue Session',
          type: 'primary',
          action: 'continue',
          onClick: () => {
            this.lastActivity = Date.now();
            this.warningShown = false;
          }
        }
      ]
    }).open();
  }

  static handleExpiration() {
    window.Utils?.showToast('Your session has expired. Please login again.', 3000, 'warning');
    AuthGuard.logout();
  }
}

// Permission Management
class Permission {
  static has(permission) {
    const user = window.appStore?.getState()?.user;
    if (!user) return false;

    if (Array.isArray(user.permissions)) {
      return user.permissions.includes(permission);
    }

    return user[permission] === true;
  }

  static require(permission) {
    if (!this.has(permission)) {
      throw new Error(`Permission denied: ${permission}`);
    }
  }

  static canEdit(resource, userId) {
    const currentUser = window.appStore?.getState()?.user;
    return currentUser?.id === userId || currentUser?.isAdmin === true;
  }

  static canDelete(resource, userId) {
    return this.canEdit(resource, userId);
  }

  static canView(resource, userId) {
    const currentUser = window.appStore?.getState()?.user;
    return true; // Most resources are viewable
  }
}

// Request Interceptor for authentication
class RequestInterceptor {
  static init() {
    const originalFetch = window.fetch;

    window.fetch = function(...args) {
      const [resource, config] = args;

      // Add auth token to all requests
      const token = AuthGuard.getToken();
      if (token && !config?.headers?.Authorization) {
        if (!config) args[1] = {};
        if (!config.headers) config.headers = {};
        config.headers.Authorization = `Bearer ${token}`;
      }

      return originalFetch.apply(this, args)
        .then(response => {
          // Handle 401 responses
          if (response.status === 401) {
            AuthGuard.logout();
          }
          return response;
        })
        .catch(error => {
          console.error('Request error:', error);
          throw error;
        });
    };
  }
}

// Initialize authentication system
document.addEventListener('DOMContentLoaded', async () => {
  RequestInterceptor.init();

  // Check if user is already authenticated
  const token = AuthGuard.getToken();
  if (token) {
    const user = await AuthGuard.checkAuth();
    if (user && window.realtimeClient) {
      window.initRealtimeClient(user.id, token);
    }
  }

  SessionManager.init();
});

// Export auth components
window.AuthGuard = AuthGuard;
window.RouteGuard = RouteGuard;
window.SessionManager = SessionManager;
window.Permission = Permission;
window.RequestInterceptor = RequestInterceptor;

export { AuthGuard, RouteGuard, SessionManager, Permission, RequestInterceptor };
