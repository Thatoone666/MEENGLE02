/**
 * Advanced Filters Service
 * Manages filtering logic for matches
 */

class AdvancedFiltersService {
  constructor() {
    this.filterOptions = {
      ageRange: {
        min: 18,
        max: 99,
        default: { min: 18, max: 65 },
      },
      distance: {
        min: 1,
        max: 500,
        default: 50,
        unit: 'km',
      },
      height: {
        min: 140,
        max: 220,
        default: { min: 140, max: 220 },
        unit: 'cm',
      },
      ethnicity: [
        'African',
        'Arab',
        'Asian',
        'Black',
        'Caucasian',
        'East Asian',
        'Hispanic',
        'Indian',
        'Middle Eastern',
        'Mixed',
        'Native American',
        'Pacific Islander',
        'South Asian',
        'Southeast Asian',
        'Other',
        'Prefer not to say',
      ],
      religion: [
        'Christian',
        'Muslim',
        'Jewish',
        'Hindu',
        'Buddhist',
        'Atheist',
        'Agnostic',
        'Spiritual',
        'Other',
        'Prefer not to say',
      ],
      bodyType: [
        'Slim',
        'Athletic',
        'Average',
        'Curvy',
        'Muscular',
        'Prefer not to say',
      ],
      educationLevel: [
        'High School',
        'Some College',
        'Bachelor',
        'Master',
        'PhD',
        'Trade School',
        'Other',
        'Prefer not to say',
      ],
      relationshipGoal: [
        'Casual Dating',
        'Serious Relationship',
        'Just Dates',
        'Friends First',
        'Open to Anything',
        'Prefer not to say',
      ],
      smoking: ['Never', 'Socially', 'Regularly', 'Prefer not to say'],
      drinking: ['Never', 'Rarely', 'Sometimes', 'Often', 'Prefer not to say'],
      interests: [
        'Travel',
        'Sports',
        'Art',
        'Music',
        'Photography',
        'Cooking',
        'Reading',
        'Gaming',
        'Movies',
        'Fitness',
        'Hiking',
        'Fashion',
        'Technology',
        'Volunteering',
        'Nightlife',
        'Yoga',
        'Meditation',
        'Dancing',
      ],
      onlineStatus: ['Online now', 'Active today', 'Active this week', 'Any'],
      verification: ['Verified only', 'Any'],
      hasPhotos: ['Photos only', 'Any'],
      likedYou: ['Liked me', 'Any'],
    };
  }

  /**
   * Get saved filters for user
   */
  async getSavedFilters(userId) {
    try {
      const response = await fetch(`/api/v1/users/${userId}/filters`, {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) return this.getDefaultFilters();
      return await response.json();
    } catch (error) {
      console.error('Error fetching saved filters:', error);
      return this.getDefaultFilters();
    }
  }

  /**
   * Save filters for user
   */
  async saveFilters(userId, filters) {
    try {
      const response = await fetch(`/api/v1/users/${userId}/filters`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
        body: JSON.stringify(filters),
      });

      if (!response.ok) throw new Error('Failed to save filters');
      return await response.json();
    } catch (error) {
      console.error('Error saving filters:', error);
      throw error;
    }
  }

  /**
   * Get default filters
   */
  getDefaultFilters() {
    return {
      ageRange: this.filterOptions.ageRange.default,
      distance: this.filterOptions.distance.default,
      height: this.filterOptions.height.default,
      ethnicity: [],
      religion: [],
      bodyType: [],
      educationLevel: [],
      relationshipGoal: [],
      smoking: [],
      drinking: [],
      interests: [],
      onlineStatus: 'Any',
      verification: 'Any',
      hasPhotos: 'Any',
      likedYou: 'Any',
    };
  }

  /**
   * Apply filters to matches
   */
  async applyFilters(matches, filters) {
    return matches.filter((match) => {
      // Age range
      if (
        match.age < filters.ageRange.min ||
        match.age > filters.ageRange.max
      ) {
        return false;
      }

      // Distance
      if (match.distance > filters.distance) {
        return false;
      }

      // Height
      if (
        match.height < filters.height.min ||
        match.height > filters.height.max
      ) {
        return false;
      }

      // Ethnicity
      if (
        filters.ethnicity.length > 0 &&
        !filters.ethnicity.includes(match.ethnicity)
      ) {
        return false;
      }

      // Religion
      if (
        filters.religion.length > 0 &&
        !filters.religion.includes(match.religion)
      ) {
        return false;
      }

      // Body type
      if (
        filters.bodyType.length > 0 &&
        !filters.bodyType.includes(match.bodyType)
      ) {
        return false;
      }

      // Education level
      if (
        filters.educationLevel.length > 0 &&
        !filters.educationLevel.includes(match.educationLevel)
      ) {
        return false;
      }

      // Relationship goal
      if (
        filters.relationshipGoal.length > 0 &&
        !filters.relationshipGoal.includes(match.relationshipGoal)
      ) {
        return false;
      }

      // Smoking
      if (
        filters.smoking.length > 0 &&
        !filters.smoking.includes(match.smoking)
      ) {
        return false;
      }

      // Drinking
      if (
        filters.drinking.length > 0 &&
        !filters.drinking.includes(match.drinking)
      ) {
        return false;
      }

      // Interests
      if (filters.interests.length > 0) {
        const hasMatchingInterest = match.interests.some((interest) =>
          filters.interests.includes(interest)
        );
        if (!hasMatchingInterest) return false;
      }

      // Online status
      if (filters.onlineStatus !== 'Any') {
        if (
          filters.onlineStatus === 'Online now' &&
          !match.isOnline
        ) {
          return false;
        }
        if (
          filters.onlineStatus === 'Active today' &&
          !match.activeToday
        ) {
          return false;
        }
        if (
          filters.onlineStatus === 'Active this week' &&
          !match.activeThisWeek
        ) {
          return false;
        }
      }

      // Verification
      if (
        filters.verification === 'Verified only' &&
        !match.isVerified
      ) {
        return false;
      }

      // Has photos
      if (
        filters.hasPhotos === 'Photos only' &&
        match.photos.length === 0
      ) {
        return false;
      }

      // Liked you
      if (
        filters.likedYou === 'Liked me' &&
        !match.likedMe
      ) {
        return false;
      }

      return true;
    });
  }

  /**
   * Reset filters to default
   */
  resetFilters() {
    return this.getDefaultFilters();
  }

  /**
   * Get filter options for UI
   */
  getFilterOptions() {
    return this.filterOptions;
  }

  /**
   * Check if filters are active (not default)
   */
  areFiltersActive(filters) {
    const defaultFilters = this.getDefaultFilters();
    return JSON.stringify(filters) !== JSON.stringify(defaultFilters);
  }

  /**
   * Get auth token from localStorage
   */
  getAuthToken() {
    return localStorage.getItem('authToken') || '';
  }
}

export default new AdvancedFiltersService();
