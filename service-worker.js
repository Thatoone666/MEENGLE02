// Service Worker for Meengle PWA
// Enables offline functionality, caching, and push notifications

const CACHE_NAME = 'meengle-v1';
const RUNTIME_CACHE = 'meengle-runtime-v1';
const ASSETS_CACHE = 'meengle-assets-v1';

// Assets to cache on install
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/assets/css/main.css',
  '/assets/css/responsive.css',
  '/assets/css/premium-style.css',
  '/assets/js/utils.js',
  '/assets/js/api-client.js',
  '/assets/js/auth-guard.js',
  '/assets/js/modal.js',
  '/assets/js/loading.js',
  '/assets/js/error-handler.js',
  '/assets/js/form-builder.js',
  '/assets/js/analytics.js',
  '/assets/js/offline.js',
  '/assets/js/i18n.js',
  '/assets/js/store.js',
  '/assets/js/realtime-client.js',
  '/assets/js/dashboard.js',
  '/assets/js/notifications.js',
  '/pages/login.html',
  '/pages/home.html',
  '/pages/matches.html',
  '/pages/chat.html',
  '/pages/dashboard.html',
  '/pages/create-profile.html',
  '/pages/payment.html',
  '/pages/terms.html',
  '/pages/privacy.html',
  '/pages/legal.html',
  '/pages/help.html',
  '/pages/faq.html',
  '/pages/community-guidelines.html',
  '/pages/cookies.html'
];

// Install event - cache static assets
self.addEventListener('install', event => {
  console.log('Service Worker installing...');

  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      console.log('Caching static assets');
      return cache.addAll(STATIC_ASSETS);
    }).catch(error => {
      console.error('Cache installation failed:', error);
    })
  );

  // Skip waiting to activate immediately
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  console.log('Service Worker activating...');

  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME && 
              cacheName !== RUNTIME_CACHE && 
              cacheName !== ASSETS_CACHE) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );

  // Claim all clients
  self.clients.claim();
});

// Fetch event - serve from cache, fall back to network
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET requests and external URLs
  if (request.method !== 'GET') {
    return;
  }

  // Handle API requests
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(
      fetch(request)
        .then(response => {
          // Cache successful API responses
          if (response.status === 200) {
            const cache = caches.open(RUNTIME_CACHE);
            cache.then(c => c.put(request, response.clone()));
          }
          return response;
        })
        .catch(() => {
          // Fall back to cached response on network error
          return caches.match(request);
        })
    );
    return;
  }

  // Handle asset requests (images, scripts, styles)
  if (request.destination === 'image' || 
      request.destination === 'script' || 
      request.destination === 'style') {
    event.respondWith(
      caches.match(request).then(response => {
        return response || fetch(request).then(response => {
          if (response.status === 200) {
            caches.open(ASSETS_CACHE).then(cache => {
              cache.put(request, response.clone());
            });
          }
          return response;
        }).catch(() => {
          // Return a placeholder for failed images
          if (request.destination === 'image') {
            return caches.match('/assets/images/placeholder.png');
          }
          return new Response('Offline', { status: 503 });
        });
      })
    );
    return;
  }

  // Default: Network first, fall back to cache
  event.respondWith(
    fetch(request)
      .then(response => {
        // Only cache successful responses
        if (response.status === 200) {
          const responseClone = response.clone();
          caches.open(RUNTIME_CACHE).then(cache => {
            cache.put(request, responseClone);
          });
        }
        return response;
      })
      .catch(() => {
        // Try to serve from cache on network error
        return caches.match(request).then(response => {
          return response || new Response(
            'You are offline. Some features may not be available.',
            { status: 503, statusText: 'Service Unavailable' }
          );
        });
      })
  );
});

// Background sync for offline messages
self.addEventListener('sync', event => {
  console.log('Background sync event:', event.tag);

  if (event.tag === 'sync-messages') {
    event.waitUntil(syncOfflineMessages());
  } else if (event.tag === 'sync-profile') {
    event.waitUntil(syncProfileChanges());
  }
});

// Sync offline messages
async function syncOfflineMessages() {
  try {
    const db = await openDatabase();
    const messages = await getOfflineMessages(db);
    
    for (const message of messages) {
      const response = await fetch('/api/messages/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(message)
      });

      if (response.ok) {
        await deleteOfflineMessage(db, message.id);
      }
    }
  } catch (error) {
    console.error('Failed to sync messages:', error);
    throw error; // Retry background sync
  }
}

// Sync profile changes
async function syncProfileChanges() {
  try {
    const db = await openDatabase();
    const changes = await getUnsyncedChanges(db);
    
    if (changes) {
      const response = await fetch('/api/profile/update', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(changes)
      });

      if (response.ok) {
        await markChangesSynced(db);
      }
    }
  } catch (error) {
    console.error('Failed to sync profile:', error);
    throw error; // Retry background sync
  }
}

// IndexedDB helpers
function openDatabase() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open('meengle', 1);
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
    request.onupgradeneeded = (event) => {
      const db = event.target.result;
      
      if (!db.objectStoreNames.contains('messages')) {
        db.createObjectStore('messages', { keyPath: 'id' });
      }
      if (!db.objectStoreNames.contains('profile')) {
        db.createObjectStore('profile', { keyPath: 'id' });
      }
    };
  });
}

function getOfflineMessages(db) {
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(['messages'], 'readonly');
    const store = transaction.objectStore('messages');
    const request = store.getAll();
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
  });
}

function deleteOfflineMessage(db, id) {
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(['messages'], 'readwrite');
    const store = transaction.objectStore('messages');
    const request = store.delete(id);
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve();
  });
}

function getUnsyncedChanges(db) {
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(['profile'], 'readonly');
    const store = transaction.objectStore('profile');
    const request = store.get('unsyncedChanges');
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
  });
}

function markChangesSynced(db) {
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(['profile'], 'readwrite');
    const store = transaction.objectStore('profile');
    const request = store.delete('unsyncedChanges');
    
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve();
  });
}

// Push notification event
self.addEventListener('push', event => {
  console.log('Push notification received');

  if (!event.data) {
    console.log('Push notification has no data');
    return;
  }

  let notificationData = {
    title: 'Meengle',
    body: 'You have a new notification',
    icon: '/assets/icons/icon-192x192.png',
    badge: '/assets/icons/icon-72x72.png',
    tag: 'meengle-notification'
  };

  try {
    notificationData = event.data.json();
  } catch (e) {
    notificationData.body = event.data.text();
  }

  event.waitUntil(
    self.registration.showNotification(notificationData.title, {
      body: notificationData.body,
      icon: notificationData.icon,
      badge: notificationData.badge,
      tag: notificationData.tag,
      data: notificationData.data || {},
      requireInteraction: false,
      actions: [
        {
          action: 'open',
          title: 'Open'
        },
        {
          action: 'close',
          title: 'Close'
        }
      ]
    })
  );
});

// Notification click event
self.addEventListener('notificationclick', event => {
  console.log('Notification clicked:', event.action);

  event.notification.close();

  if (event.action === 'close') {
    return;
  }

  // Open the app or navigate to relevant page
  const urlToOpen = event.notification.data?.url || '/';

  event.waitUntil(
    clients.matchAll({
      type: 'window',
      includeUncontrolled: true
    }).then(clientList => {
      // Check if app is already open
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url === urlToOpen && 'focus' in client) {
          return client.focus();
        }
      }
      // If not open, open new window
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});

// Message event - receive messages from client
self.addEventListener('message', event => {
  console.log('Service Worker received message:', event.data);

  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }

  if (event.data && event.data.type === 'CACHE_URLS') {
    event.waitUntil(
      caches.open(ASSETS_CACHE).then(cache => {
        return cache.addAll(event.data.urls || []);
      })
    );
  }
});

console.log('Service Worker loaded and ready');
