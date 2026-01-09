// MEENGLE - Geolocation Service
// Handles user location tracking and distance calculations

class GeolocationService {
  constructor() {
    this.currentLocation = null;
    this.watchId = null;
    this.listeners = {};
  }

  // Check if geolocation is supported
  isSupported() {
    return 'geolocation' in navigator;
  }

  // Get current position
  async getCurrentPosition() {
    return new Promise((resolve, reject) => {
      if (!this.isSupported()) {
        reject(new Error('Geolocation not supported'));
        return;
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.currentLocation = {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy,
            timestamp: new Date(position.timestamp)
          };
          this.emit('location-updated', this.currentLocation);
          resolve(this.currentLocation);
        },
        (error) => {
          let message = 'Unknown error';
          if (error.code === error.PERMISSION_DENIED) {
            message = 'User denied location permission';
          } else if (error.code === error.POSITION_UNAVAILABLE) {
            message = 'Location information unavailable';
          } else if (error.code === error.TIMEOUT) {
            message = 'Location request timed out';
          }
          reject(new Error(message));
        },
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 0
        }
      );
    });
  }

  // Watch position (continuous updates)
  watchPosition() {
    if (!this.isSupported()) {
      console.error('Geolocation not supported');
      return false;
    }

    this.watchId = navigator.geolocation.watchPosition(
      (position) => {
        this.currentLocation = {
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
          timestamp: new Date(position.timestamp)
        };
        this.emit('location-updated', this.currentLocation);
      },
      (error) => {
        console.error('Geolocation error:', error);
        this.emit('location-error', error);
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    );

    return this.watchId !== null;
  }

  // Stop watching position
  stopWatching() {
    if (this.watchId !== null) {
      navigator.geolocation.clearWatch(this.watchId);
      this.watchId = null;
      return true;
    }
    return false;
  }

  // Calculate distance between two points (haversine formula)
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in km
    const dLat = this.degreesToRadians(lat2 - lat1);
    const dLon = this.degreesToRadians(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.degreesToRadians(lat1)) *
        Math.cos(this.degreesToRadians(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;
    return Math.round(distance * 10) / 10; // Round to 1 decimal
  }

  // Degrees to radians
  degreesToRadians(degrees) {
    return (degrees * Math.PI) / 180;
  }

  // Get current location
  getLocation() {
    return this.currentLocation;
  }

  // Check distance from current location
  getDistance(targetLat, targetLon) {
    if (!this.currentLocation) {
      return null;
    }
    return this.calculateDistance(
      this.currentLocation.latitude,
      this.currentLocation.longitude,
      targetLat,
      targetLon
    );
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

  // Request permission (for browsers that require explicit permission)
  async requestPermission() {
    if (!this.isSupported()) {
      return false;
    }

    try {
      const permission = await navigator.permissions.query({ name: 'geolocation' });
      return permission.state === 'granted';
    } catch (error) {
      console.error('Permission query error:', error);
      return false;
    }
  }
}

// Create global instance
window.geolocationService = new GeolocationService();

// Export for use in modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = GeolocationService;
}
