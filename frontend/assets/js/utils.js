// Meengle Frontend Utilities Library
class Utils {
  // DOM Utilities
  static $(selector) {
    return document.querySelector(selector);
  }

  static $$(selector) {
    return document.querySelectorAll(selector);
  }

  static createElement(tag, className = '', innerHTML = '') {
    const element = document.createElement(tag);
    if (className) element.className = className;
    if (innerHTML) element.innerHTML = innerHTML;
    return element;
  }

  static addClass(element, className) {
    element.classList.add(className);
  }

  static removeClass(element, className) {
    element.classList.remove(className);
  }

  static toggleClass(element, className) {
    element.classList.toggle(className);
  }

  static hasClass(element, className) {
    return element.classList.contains(className);
  }

  static setAttributes(element, attributes) {
    Object.entries(attributes).forEach(([key, value]) => {
      element.setAttribute(key, value);
    });
  }

  static on(element, event, handler) {
    element.addEventListener(event, handler);
  }

  static off(element, event, handler) {
    element.removeEventListener(event, handler);
  }

  // Storage Utilities
  static getFromStorage(key) {
    try {
      return JSON.parse(localStorage.getItem(key));
    } catch {
      return localStorage.getItem(key);
    }
  }

  static saveToStorage(key, value) {
    localStorage.setItem(key, typeof value === 'string' ? value : JSON.stringify(value));
  }

  static removeFromStorage(key) {
    localStorage.removeItem(key);
  }

  static clearStorage() {
    localStorage.clear();
  }

  // String Utilities
  static formatDate(date, format = 'short') {
    const d = new Date(date);
    if (format === 'short') {
      return d.toLocaleDateString();
    } else if (format === 'time') {
      return d.toLocaleTimeString();
    } else if (format === 'full') {
      return d.toLocaleString();
    }
    return d.toString();
  }

  static formatTime(timestamp) {
    const now = new Date();
    const then = new Date(timestamp);
    const diff = Math.floor((now - then) / 1000);

    if (diff < 60) return 'just now';
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
    if (diff < 604800) return `${Math.floor(diff / 86400)}d ago`;
    
    return then.toLocaleDateString();
  }

  static truncate(str, length = 100) {
    return str.length > length ? str.substring(0, length) + '...' : str;
  }

  static slugify(str) {
    return str
      .toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/[\s_-]+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  static capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  // Validation Utilities
  static isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  static isValidPassword(password) {
    return password && password.length >= 8;
  }

  static isValidPhone(phone) {
    return /^[\d\s\-\(\)\+]+$/.test(phone) && phone.replace(/\D/g, '').length >= 10;
  }

  static isValidURL(url) {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  // Object Utilities
  static deepClone(obj) {
    return JSON.parse(JSON.stringify(obj));
  }

  static mergeObjects(target, source) {
    return { ...target, ...source };
  }

  static getNestedValue(obj, path) {
    return path.split('.').reduce((current, prop) => current?.[prop], obj);
  }

  static setNestedValue(obj, path, value) {
    const keys = path.split('.');
    let current = obj;
    for (let i = 0; i < keys.length - 1; i++) {
      const key = keys[i];
      current[key] = current[key] || {};
      current = current[key];
    }
    current[keys[keys.length - 1]] = value;
  }

  // Array Utilities
  static unique(arr) {
    return [...new Set(arr)];
  }

  static chunk(arr, size) {
    const chunks = [];
    for (let i = 0; i < arr.length; i += size) {
      chunks.push(arr.slice(i, i + size));
    }
    return chunks;
  }

  static flatten(arr) {
    return arr.reduce((flat, current) => 
      flat.concat(Array.isArray(current) ? Utils.flatten(current) : current), []);
  }

  static sortBy(arr, key) {
    return [...arr].sort((a, b) => {
      if (a[key] < b[key]) return -1;
      if (a[key] > b[key]) return 1;
      return 0;
    });
  }

  // Network Utilities
  static async fetchWithRetry(url, options = {}, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
      try {
        return await fetch(url, options);
      } catch (error) {
        if (i === maxRetries - 1) throw error;
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
      }
    }
  }

  static async timeout(promise, ms) {
    return Promise.race([
      promise,
      new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Timeout')), ms)
      )
    ]);
  }

  // Event Utilities
  static debounce(func, delay) {
    let timeoutId;
    return function (...args) {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => func(...args), delay);
    };
  }

  static throttle(func, limit) {
    let inThrottle;
    return function (...args) {
      if (!inThrottle) {
        func(...args);
        inThrottle = true;
        setTimeout(() => inThrottle = false, limit);
      }
    };
  }

  // Math Utilities
  static calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  static randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  static average(arr) {
    return arr.reduce((a, b) => a + b) / arr.length;
  }

  // Notification Utilities
  static showNotification(title, options = {}) {
    if ('Notification' in window) {
      if (Notification.permission === 'granted') {
        new Notification(title, options);
      } else if (Notification.permission !== 'denied') {
        Notification.requestPermission().then(permission => {
          if (permission === 'granted') {
            new Notification(title, options);
          }
        });
      }
    }
  }

  static showToast(message, duration = 3000, type = 'info') {
    const toast = this.createElement('div', `toast toast-${type}`, message);
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), duration);
  }

  // Analytics Utilities
  static trackEvent(eventName, eventData = {}) {
    if (window.posthog) {
      window.posthog.capture(eventName, eventData);
    }
  }

  static trackPageView(pageName) {
    if (window.posthog) {
      window.posthog.capture('$pageview', { page: pageName });
    }
  }

  // Error Utilities
  static logError(error, context = {}) {
    console.error('Error:', error);
    if (window.Sentry) {
      window.Sentry.captureException(error, { contexts: { custom: context } });
    }
  }

  static logMessage(message, level = 'info') {
    console.log(`[${level.toUpperCase()}]`, message);
    if (window.Sentry && level === 'error') {
      window.Sentry.captureMessage(message, level);
    }
  }
}

// Export and make available globally
if (typeof module !== 'undefined' && module.exports) {
  module.exports = Utils;
}

window.Utils = Utils;
