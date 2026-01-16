/**
 * Check-In Service
 * Manages location-based check-ins and interactions with nearby users
 */

class CheckInService {
  constructor() {
    this.checkInTypes = [
      'Hotel',
      'Resort',
      'Vacation',
      'School',
      'University',
      'Workplace',
      'Conference',
      'Festival',
      'Event',
      'Travel',
      'Retreat',
      'Staycation',
      'Study Abroad',
      'Business Trip',
      'Other',
    ];

    this.checkInStatuses = [
      'Checked In',
      'Interested',
      'Looking to Meet',
      'Casual',
      'Social',
    ];

    this.visibilityLevels = [
      'Everyone',
      'Nearby Only',
      'My Interests Only',
      'Verified Only',
    ];
  }

  /**
   * Create a check-in
   */
  async createCheckIn(userId, checkInData) {
    try {
      const response = await fetch('/api/v1/check-ins', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          userId,
          type: checkInData.type,
          location: checkInData.location,
          coordinates: checkInData.coordinates,
          status: checkInData.status,
          visibility: checkInData.visibility,
          interests: checkInData.interests || [],
          photos: checkInData.photos || [],
          description: checkInData.description || '',
        }),
      });

      if (!response.ok) throw new Error('Failed to create check-in');
      return await response.json();
    } catch (error) {
      console.error('Error creating check-in:', error);
      throw error;
    }
  }

  /**
   * Get active check-ins for user
   */
  async getMyCheckIns(userId) {
    try {
      const response = await fetch(`/api/v1/users/${userId}/check-ins`, {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching check-ins:', error);
      return [];
    }
  }

  /**
   * Get nearby check-ins based on location
   */
  async getNearbyCheckIns(latitude, longitude, radiusKm = 5, filters = {}) {
    try {
      const queryParams = new URLSearchParams({
        latitude,
        longitude,
        radius: radiusKm,
        ...filters,
      });

      const response = await fetch(
        `/api/v1/check-ins/nearby?${queryParams}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching nearby check-ins:', error);
      return [];
    }
  }

  /**
   * Get check-ins by type
   */
  async getCheckInsByType(type, filters = {}) {
    try {
      const queryParams = new URLSearchParams({
        type,
        ...filters,
      });

      const response = await fetch(
        `/api/v1/check-ins/by-type?${queryParams}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching check-ins by type:', error);
      return [];
    }
  }

  /**
   * Update check-in
   */
  async updateCheckIn(checkInId, updateData) {
    try {
      const response = await fetch(`/api/v1/check-ins/${checkInId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify(updateData),
      });

      if (!response.ok) throw new Error('Failed to update check-in');
      return await response.json();
    } catch (error) {
      console.error('Error updating check-in:', error);
      throw error;
    }
  }

  /**
   * End/delete check-in
   */
  async endCheckIn(checkInId) {
    try {
      const response = await fetch(`/api/v1/check-ins/${checkInId}`, {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to end check-in');
      return await response.json();
    } catch (error) {
      console.error('Error ending check-in:', error);
      throw error;
    }
  }

  /**
   * Get check-in details
   */
  async getCheckInDetails(checkInId) {
    try {
      const response = await fetch(`/api/v1/check-ins/${checkInId}`, {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to fetch check-in details');
      return await response.json();
    } catch (error) {
      console.error('Error fetching check-in details:', error);
      throw error;
    }
  }

  /**
   * Like/interact with check-in
   */
  async likeCheckIn(checkInId, userId) {
    try {
      const response = await fetch(`/api/v1/check-ins/${checkInId}/like`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({ userId }),
      });

      if (!response.ok) throw new Error('Failed to like check-in');
      return await response.json();
    } catch (error) {
      console.error('Error liking check-in:', error);
      throw error;
    }
  }

  /**
   * Unlike check-in
   */
  async unlikeCheckIn(checkInId, userId) {
    try {
      const response = await fetch(`/api/v1/check-ins/${checkInId}/unlike`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({ userId }),
      });

      if (!response.ok) throw new Error('Failed to unlike check-in');
      return await response.json();
    } catch (error) {
      console.error('Error unliking check-in:', error);
      throw error;
    }
  }

  /**
   * View check-in (for analytics)
   */
  async viewCheckIn(checkInId) {
    try {
      await fetch(`/api/v1/check-ins/${checkInId}/view`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });
    } catch (error) {
      console.error('Error recording view:', error);
    }
  }

  /**
   * Send message to check-in user
   */
  async sendMessage(checkInId, recipientId, message) {
    try {
      const response = await fetch('/api/v1/messages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          checkInId,
          recipientId,
          message,
          type: 'check_in',
        }),
      });

      if (!response.ok) throw new Error('Failed to send message');
      return await response.json();
    } catch (error) {
      console.error('Error sending message:', error);
      throw error;
    }
  }

  /**
   * Filter check-ins by user preferences
   */
  async filterCheckIns(checkIns, filters) {
    return checkIns.filter((checkIn) => {
      // Check-in type filter
      if (
        filters.types &&
        filters.types.length > 0 &&
        !filters.types.includes(checkIn.type)
      ) {
        return false;
      }

      // Status filter
      if (
        filters.statuses &&
        filters.statuses.length > 0 &&
        !filters.statuses.includes(checkIn.status)
      ) {
        return false;
      }

      // Interests filter
      if (filters.interests && filters.interests.length > 0) {
        const hasMatchingInterest = checkIn.interests.some((interest) =>
          filters.interests.includes(interest)
        );
        if (!hasMatchingInterest) return false;
      }

      // Distance filter
      if (filters.maxDistance && checkIn.distance > filters.maxDistance) {
        return false;
      }

      // Verification filter
      if (
        filters.verifiedOnly &&
        filters.verifiedOnly === true &&
        !checkIn.user.isVerified
      ) {
        return false;
      }

      // Photo filter
      if (
        filters.photosOnly &&
        filters.photosOnly === true &&
        checkIn.photos.length === 0
      ) {
        return false;
      }

      return true;
    });
  }

  /**
   * Get check-in filter options
   */
  getFilterOptions() {
    return {
      types: this.checkInTypes,
      statuses: this.checkInStatuses,
      visibilityLevels: this.visibilityLevels,
    };
  }

  /**
   * Format check-in for display
   */
  formatCheckIn(checkIn) {
    return {
      ...checkIn,
      displayName: checkIn.user.name,
      displayAge: checkIn.user.age,
      displayPhoto: checkIn.photos[0] || checkIn.user.photos[0],
      displayLocation: `${checkIn.location.name}, ${checkIn.location.city}`,
      timeAgo: this.getTimeAgo(checkIn.createdAt),
    };
  }

  /**
   * Get time ago string
   */
  getTimeAgo(date) {
    const now = new Date();
    const checkInDate = new Date(date);
    const diffMs = now - checkInDate;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;

    return checkInDate.toLocaleDateString();
  }

  /**
   * Get auth token
   */
  getAuthToken() {
    return localStorage.getItem('authToken') || '';
  }
}

export default new CheckInService();
