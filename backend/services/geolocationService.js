const axios = require('axios');
const logger = require('../config/logger');

class GeolocationService {
  constructor() {
    this.googleMapsApiKey = process.env.GOOGLE_MAPS_API_KEY;
    this.baseUrl = 'https://maps.googleapis.com/maps/api';
  }

  /**
   * Get coordinates from address
   */
  async geocodeAddress(address) {
    try {
      const response = await axios.get(`${this.baseUrl}/geocode/json`, {
        params: {
          address,
          key: this.googleMapsApiKey,
        },
      });

      if (response.data.results.length === 0) {
        throw new Error('Address not found');
      }

      const location = response.data.results[0].geometry.location;
      logger.info('Address geocoded', { 
        address, 
        lat: location.lat, 
        lng: location.lng 
      });

      return {
        latitude: location.lat,
        longitude: location.lng,
        address: response.data.results[0].formatted_address,
      };
    } catch (error) {
      logger.error('Geocoding failed', { 
        address, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Get address from coordinates
   */
  async reverseGeocode(latitude, longitude) {
    try {
      const response = await axios.get(`${this.baseUrl}/geocode/json`, {
        params: {
          latlng: `${latitude},${longitude}`,
          key: this.googleMapsApiKey,
        },
      });

      if (response.data.results.length === 0) {
        throw new Error('Location not found');
      }

      const address = response.data.results[0].formatted_address;
      logger.info('Coordinates reverse geocoded', { 
        latitude, 
        longitude, 
        address 
      });

      return address;
    } catch (error) {
      logger.error('Reverse geocoding failed', { 
        latitude, 
        longitude, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Calculate distance between two points
   */
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the earth in km
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
    return parseFloat(distance.toFixed(2));
  }

  /**
   * Find users within radius
   */
  findUsersWithinRadius(userLocation, otherUsers, radiusKm) {
    const nearbyUsers = otherUsers.filter(user => {
      const distance = this.calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        user.location.latitude,
        user.location.longitude
      );
      return distance <= radiusKm;
    });

    return nearbyUsers.sort((a, b) => {
      const distanceA = this.calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        a.location.latitude,
        a.location.longitude
      );
      const distanceB = this.calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        b.location.latitude,
        b.location.longitude
      );
      return distanceA - distanceB;
    });
  }

  /**
   * Validate location coordinates
   */
  isValidLocation(latitude, longitude) {
    return (
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180
    );
  }

  /**
   * Get timezone from coordinates
   */
  async getTimezone(latitude, longitude) {
    try {
      const response = await axios.get(`${this.baseUrl}/timezone/json`, {
        params: {
          location: `${latitude},${longitude}`,
          timestamp: Math.floor(Date.now() / 1000),
          key: this.googleMapsApiKey,
        },
      });

      return response.data.timeZoneId;
    } catch (error) {
      logger.warn('Failed to get timezone', { 
        error: error.message 
      });
      return null;
    }
  }

  /**
   * Get place details
   */
  async getPlaceDetails(placeId) {
    try {
      const response = await axios.get(`${this.baseUrl}/place/details/json`, {
        params: {
          place_id: placeId,
          key: this.googleMapsApiKey,
        },
      });

      return response.data.result;
    } catch (error) {
      logger.error('Failed to get place details', { 
        placeId, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Helper: degrees to radians
   */
  degreesToRadians(degrees) {
    return degrees * (Math.PI / 180);
  }
}

module.exports = new GeolocationService();
