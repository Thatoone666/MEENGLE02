/**
 * Activity Planning Service
 * Enables users to create, discover, and join group activities
 */

class ActivityPlanningService {
  constructor() {
    this.activityCategories = [
      'Sports & Fitness',
      'Arts & Culture',
      'Food & Dining',
      'Adventure & Outdoor',
      'Gaming & Esports',
      'Music & Entertainment',
      'Learning & Workshops',
      'Wellness & Yoga',
      'Travel & Exploration',
      'Social & Networking',
      'Movie & Cinema',
      'Photography',
      'Book Club',
      'Volunteering',
      'Beach & Water Sports',
      'Hiking & Nature',
      'Fitness Classes',
      'Cooking Classes',
      'Language Exchange',
      'Pet Friendly',
    ];

    this.skillLevels = ['Beginner', 'Intermediate', 'Advanced', 'Any'];

    this.groupSizes = [
      '1-2 people',
      '3-5 people',
      '6-10 people',
      '10+ people',
      'No limit',
    ];

    this.ageRanges = [
      '18-21',
      '22-25',
      '26-30',
      '31-35',
      'Mixed',
    ];
  }

  /**
   * Create activity
   */
  async createActivity(userId, activityData) {
    try {
      const response = await fetch('/api/v1/activities', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({
          userId,
          title: activityData.title,
          description: activityData.description,
          category: activityData.category,
          location: activityData.location,
          coordinates: activityData.coordinates,
          startTime: activityData.startTime,
          endTime: activityData.endTime,
          skillLevel: activityData.skillLevel,
          maxParticipants: activityData.maxParticipants,
          ageRange: activityData.ageRange,
          cost: activityData.cost || 0,
          tags: activityData.tags || [],
          photos: activityData.photos || [],
          requiredEquipment: activityData.requiredEquipment || [],
        }),
      });

      if (!response.ok) throw new Error('Failed to create activity');
      return await response.json();
    } catch (error) {
      console.error('Error creating activity:', error);
      throw error;
    }
  }

  /**
   * Get nearby activities
   */
  async getNearbyActivities(latitude, longitude, radiusKm = 10, filters = {}) {
    try {
      const queryParams = new URLSearchParams({
        latitude,
        longitude,
        radius: radiusKm,
        ...filters,
      });

      const response = await fetch(`/api/v1/activities/nearby?${queryParams}`, {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching nearby activities:', error);
      return [];
    }
  }

  /**
   * Get activities by category
   */
  async getActivitiesByCategory(category, filters = {}) {
    try {
      const queryParams = new URLSearchParams({
        category,
        ...filters,
      });

      const response = await fetch(
        `/api/v1/activities/category?${queryParams}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching activities by category:', error);
      return [];
    }
  }

  /**
   * Join activity
   */
  async joinActivity(activityId, userId) {
    try {
      const response = await fetch(`/api/v1/activities/${activityId}/join`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({ userId }),
      });

      if (!response.ok) throw new Error('Failed to join activity');
      return await response.json();
    } catch (error) {
      console.error('Error joining activity:', error);
      throw error;
    }
  }

  /**
   * Leave activity
   */
  async leaveActivity(activityId, userId) {
    try {
      const response = await fetch(`/api/v1/activities/${activityId}/leave`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({ userId }),
      });

      if (!response.ok) throw new Error('Failed to leave activity');
      return await response.json();
    } catch (error) {
      console.error('Error leaving activity:', error);
      throw error;
    }
  }

  /**
   * Get activity details
   */
  async getActivityDetails(activityId) {
    try {
      const response = await fetch(`/api/v1/activities/${activityId}`, {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to fetch activity details');
      return await response.json();
    } catch (error) {
      console.error('Error fetching activity details:', error);
      throw error;
    }
  }

  /**
   * Update activity
   */
  async updateActivity(activityId, updateData) {
    try {
      const response = await fetch(`/api/v1/activities/${activityId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify(updateData),
      });

      if (!response.ok) throw new Error('Failed to update activity');
      return await response.json();
    } catch (error) {
      console.error('Error updating activity:', error);
      throw error;
    }
  }

  /**
   * Cancel activity
   */
  async cancelActivity(activityId) {
    try {
      const response = await fetch(`/api/v1/activities/${activityId}`, {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) throw new Error('Failed to cancel activity');
      return await response.json();
    } catch (error) {
      console.error('Error canceling activity:', error);
      throw error;
    }
  }

  /**
   * Get activity participants
   */
  async getParticipants(activityId) {
    try {
      const response = await fetch(
        `/api/v1/activities/${activityId}/participants`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching participants:', error);
      return [];
    }
  }

  /**
   * Rate activity
   */
  async rateActivity(activityId, rating, review) {
    try {
      const response = await fetch(`/api/v1/activities/${activityId}/rate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify({ rating, review }),
      });

      if (!response.ok) throw new Error('Failed to rate activity');
      return await response.json();
    } catch (error) {
      console.error('Error rating activity:', error);
      throw error;
    }
  }

  /**
   * Get user's activities
   */
  async getUserActivities(userId, filter = 'all') {
    try {
      const response = await fetch(
        `/api/v1/users/${userId}/activities?filter=${filter}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching user activities:', error);
      return [];
    }
  }

  /**
   * Get activity recommendations based on user interests
   */
  async getRecommendedActivities(userId, latitude, longitude) {
    try {
      const response = await fetch(
        `/api/v1/activities/recommended?latitude=${latitude}&longitude=${longitude}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return [];
      return await response.json();
    } catch (error) {
      console.error('Error fetching recommendations:', error);
      return [];
    }
  }

  /**
   * Get activity categories
   */
  getActivityCategories() {
    return this.activityCategories;
  }

  /**
   * Format activity for display
   */
  formatActivity(activity) {
    return {
      ...activity,
      displayTime: this.formatTime(activity.startTime),
      displayDate: this.formatDate(activity.startTime),
      timeRemaining: this.getTimeRemaining(activity.startTime),
      spotsRemaining: activity.maxParticipants - activity.participantCount,
      isFull: activity.participantCount >= activity.maxParticipants,
    };
  }

  /**
   * Format time
   */
  formatTime(date) {
    return new Date(date).toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true,
    });
  }

  /**
   * Format date
   */
  formatDate(date) {
    return new Date(date).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
    });
  }

  /**
   * Get time remaining until activity
   */
  getTimeRemaining(startTime) {
    const now = new Date();
    const activityTime = new Date(startTime);
    const diffMs = activityTime - now;

    if (diffMs < 0) return 'Happening now';

    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffHours < 1) return 'Starting soon';
    if (diffHours < 24) return `In ${diffHours}h`;
    if (diffDays < 7) return `In ${diffDays}d`;

    return 'Upcoming';
  }

  /**
   * Get auth token
   */
  getAuthToken() {
    return localStorage.getItem('authToken') || '';
  }
}

export default new ActivityPlanningService();
