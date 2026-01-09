// Service Worker Registration & Management
class ServiceWorkerManager {
  constructor(options = {}) {
    this.swPath = options.swPath || '/service-worker.js';
    this.enabled = options.enabled !== false;
    this.cacheVersion = options.cacheVersion || 'v1';
    this.cacheName = `meengle-${this.cacheVersion}`;
    this.init();
  }

  async init() {
    if (!('serviceWorker' in navigator)) {
      console.log('Service Workers not supported');
      return;
    }

    try {
      const registration = await navigator.serviceWorker.register(this.swPath);
      console.log('Service Worker registered:', registration);

      // Check for updates
      registration.addEventListener('updatefound', () => {
        const newWorker = registration.installing;
        newWorker.addEventListener('statechange', () => {
          if (newWorker.state === 'activated') {
            console.log('Service Worker updated');
            window.Utils?.showToast('App updated! Refresh to see changes.', 5000, 'info');
          }
        });
      });

      // Listen for messages from service worker
      navigator.serviceWorker.addEventListener('message', (event) => {
        this.handleServiceWorkerMessage(event.data);
      });
    } catch (error) {
      console.error('Service Worker registration failed:', error);
    }
  }

  handleServiceWorkerMessage(data) {
    const { type, payload } = data;

    switch (type) {
      case 'CACHE_UPDATED':
        console.log('Cache updated:', payload);
        break;
      case 'OFFLINE':
        window.Utils?.showToast('You are offline', 3000, 'warning');
        break;
      case 'ONLINE':
        window.Utils?.showToast('You are back online!', 3000, 'success');
        break;
    }
  }

  async sendMessage(message) {
    const controller = navigator.serviceWorker.controller;
    if (controller) {
      controller.postMessage(message);
    }
  }

  async unregister() {
    const registrations = await navigator.serviceWorker.getRegistrations();
    for (const registration of registrations) {
      await registration.unregister();
    }
  }

  isOnline() {
    return navigator.onLine;
  }
}

// Offline Storage Manager
class OfflineStorage {
  constructor(dbName = 'meengle') {
    this.dbName = dbName;
    this.db = null;
    this.init();
  }

  async init() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, 1);

      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve(this.db);
      };

      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        
        // Create object stores
        if (!db.objectStoreNames.contains('messages')) {
          db.createObjectStore('messages', { keyPath: 'id' });
        }
        if (!db.objectStoreNames.contains('posts')) {
          db.createObjectStore('posts', { keyPath: 'id' });
        }
        if (!db.objectStoreNames.contains('cache')) {
          db.createObjectStore('cache', { keyPath: 'url' });
        }
        if (!db.objectStoreNames.contains('queue')) {
          db.createObjectStore('queue', { keyPath: 'id', autoIncrement: true });
        }
      };
    });
  }

  async saveMessage(message) {
    const transaction = this.db.transaction(['messages'], 'readwrite');
    const store = transaction.objectStore('messages');
    return store.add(message);
  }

  async getMessages() {
    const transaction = this.db.transaction(['messages'], 'readonly');
    const store = transaction.objectStore('messages');
    return store.getAll();
  }

  async savePost(post) {
    const transaction = this.db.transaction(['posts'], 'readwrite');
    const store = transaction.objectStore('posts');
    return store.add(post);
  }

  async getPosts() {
    const transaction = this.db.transaction(['posts'], 'readonly');
    const store = transaction.objectStore('posts');
    return store.getAll();
  }

  async saveToCache(url, data) {
    const transaction = this.db.transaction(['cache'], 'readwrite');
    const store = transaction.objectStore('cache');
    return store.put({ url, data, timestamp: Date.now() });
  }

  async getFromCache(url) {
    const transaction = this.db.transaction(['cache'], 'readonly');
    const store = transaction.objectStore('cache');
    return store.get(url);
  }

  async queueRequest(request) {
    const transaction = this.db.transaction(['queue'], 'readwrite');
    const store = transaction.objectStore('queue');
    return store.add({
      method: request.method,
      url: request.url,
      body: request.body,
      timestamp: Date.now()
    });
  }

  async getQueue() {
    const transaction = this.db.transaction(['queue'], 'readonly');
    const store = transaction.objectStore('queue');
    return store.getAll();
  }

  async clearQueue() {
    const transaction = this.db.transaction(['queue'], 'readwrite');
    const store = transaction.objectStore('queue');
    return store.clear();
  }

  async clearAll() {
    const transaction = this.db.transaction(['messages', 'posts', 'cache', 'queue'], 'readwrite');
    ['messages', 'posts', 'cache', 'queue'].forEach(store => {
      transaction.objectStore(store).clear();
    });
  }
}

// Sync Manager (for queued actions)
class SyncManager {
  constructor() {
    this.offlineStorage = new OfflineStorage();
    this.isOnline = navigator.onLine;
    this.init();
  }

  init() {
    window.addEventListener('online', () => this.handleOnline());
    window.addEventListener('offline', () => this.handleOffline());
  }

  async handleOnline() {
    this.isOnline = true;
    console.log('Online - syncing queued requests');
    
    await this.syncQueue();
  }

  handleOffline() {
    this.isOnline = false;
    console.log('Offline - requests will be queued');
  }

  async syncQueue() {
    try {
      const queue = await this.offlineStorage.getQueue();
      
      for (const item of queue) {
        try {
          const response = await fetch(item.url, {
            method: item.method,
            body: item.body
          });

          if (response.ok) {
            // Remove from queue
            const transaction = this.offlineStorage.db.transaction(['queue'], 'readwrite');
            const store = transaction.objectStore('queue');
            store.delete(item.id);
          }
        } catch (error) {
          console.error('Sync failed for:', item.url);
        }
      }

      window.Utils?.showToast('Sync complete!', 2000, 'success');
    } catch (error) {
      console.error('Sync failed:', error);
    }
  }

  async queueApiCall(method, url, body) {
    if (this.isOnline) {
      return fetch(url, { method, body });
    } else {
      await this.offlineStorage.queueRequest({
        method,
        url,
        body
      });
      window.Utils?.showToast('Request queued for later', 2000, 'info');
    }
  }
}

// Cache Manager
class CacheManager {
  constructor() {
    this.cacheName = `meengle-${new Date().toISOString().split('T')[0]}`;
  }

  async cacheResponse(request, response) {
    try {
      const cache = await caches.open(this.cacheName);
      cache.put(request, response.clone());
    } catch (error) {
      console.error('Cache failed:', error);
    }
  }

  async getCachedResponse(request) {
    try {
      const cache = await caches.open(this.cacheName);
      return cache.match(request);
    } catch (error) {
      console.error('Cache retrieval failed:', error);
      return null;
    }
  }

  async clearOldCaches() {
    const cacheNames = await caches.keys();
    const maxAge = 7 * 24 * 60 * 60 * 1000; // 7 days

    for (const name of cacheNames) {
      const cache = await caches.open(name);
      const requests = await cache.keys();

      for (const request of requests) {
        const response = await cache.match(request);
        const date = new Date(response.headers.get('date'));

        if (Date.now() - date.getTime() > maxAge) {
          cache.delete(request);
        }
      }
    }
  }

  async precacheAssets(assets) {
    const cache = await caches.open(this.cacheName);
    return cache.addAll(assets);
  }
}

// Initialize offline support
window.ServiceWorkerManager = ServiceWorkerManager;
window.OfflineStorage = OfflineStorage;
window.SyncManager = SyncManager;
window.CacheManager = CacheManager;

// Auto-initialize if enabled
if (!window.location.pathname.includes('admin')) {
  window.serviceWorkerManager = new ServiceWorkerManager();
  window.offlineStorage = new OfflineStorage();
  window.syncManager = new SyncManager();
  window.cacheManager = new CacheManager();
}

export { ServiceWorkerManager, OfflineStorage, SyncManager, CacheManager };
