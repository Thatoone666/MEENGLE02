/**
 * Paywall Service
 * Manages feature access based on subscription tier
 */

class PaywallService {
  constructor() {
    this.tierFeatures = {
      free: {
        matches: 10, // limited
        messages: 20, // limited
        dailySwipes: 20,
        advancedFilters: false,
        videoCalls: false,
        rewindFeature: false,
        exclusiveMatches: false,
        prioritySupport: false,
        vipEvents: false,
        adFree: false,
      },
      spark: {
        matches: 50,
        messages: 100,
        dailySwipes: 50,
        advancedFilters: true,
        videoCalls: false,
        rewindFeature: false,
        exclusiveMatches: false,
        prioritySupport: false,
        vipEvents: false,
        adFree: false,
      },
      sparkplus: {
        matches: Infinity,
        messages: Infinity,
        dailySwipes: Infinity,
        advancedFilters: true,
        videoCalls: false,
        rewindFeature: true,
        exclusiveMatches: false,
        prioritySupport: true,
        vipEvents: false,
        adFree: false,
      },
      flame: {
        matches: Infinity,
        messages: Infinity,
        dailySwipes: Infinity,
        advancedFilters: true,
        videoCalls: true,
        rewindFeature: true,
        exclusiveMatches: true,
        prioritySupport: true,
        vipEvents: false,
        adFree: true,
      },
      wildfire: {
        matches: Infinity,
        messages: Infinity,
        dailySwipes: Infinity,
        advancedFilters: true,
        videoCalls: true,
        rewindFeature: true,
        exclusiveMatches: true,
        prioritySupport: true,
        vipEvents: true,
        adFree: true,
      },
    };

    this.featureDescriptions = {
      matches: 'View profiles and matches',
      messages: 'Send direct messages',
      dailySwipes: 'Number of daily likes/passes',
      advancedFilters: 'Advanced filtering options',
      videoCalls: 'Video calling with matches',
      rewindFeature: 'Undo last like/pass',
      exclusiveMatches: 'Premium profile recommendations',
      prioritySupport: 'Priority customer support',
      vipEvents: 'VIP-exclusive events access',
      adFree: 'Ad-free experience',
    };
  }

  /**
   * Get user's current tier
   */
  async getUserTier(userId) {
    try {
      const response = await fetch(`/api/v1/users/${userId}/tier`, {
        headers: {
          Authorization: `Bearer ${this.getAuthToken()}`,
        },
      });

      if (!response.ok) {
        return 'free'; // Default to free
      }

      const data = await response.json();
      return data.tier || 'free';
    } catch (error) {
      console.error('Error fetching user tier:', error);
      return 'free';
    }
  }

  /**
   * Check if feature is available for tier
   */
  canAccessFeature(tier, feature) {
    const tierFeatures = this.tierFeatures[tier];
    if (!tierFeatures) return false;

    const featureValue = tierFeatures[feature];
    if (featureValue === false) return false;
    if (featureValue === true) return true;
    if (typeof featureValue === 'number' && featureValue > 0) return true;

    return false;
  }

  /**
   * Get feature limit for tier
   */
  getFeatureLimit(tier, feature) {
    const tierFeatures = this.tierFeatures[tier];
    if (!tierFeatures) return 0;

    const limit = tierFeatures[feature];
    if (typeof limit === 'number') return limit;
    return limit === true ? Infinity : 0;
  }

  /**
   * Get all features for tier
   */
  getTierFeatures(tier) {
    return this.tierFeatures[tier] || this.tierFeatures.free;
  }

  /**
   * Get tier comparison data
   */
  getTierComparison() {
    const comparison = {};
    const features = Object.keys(this.tierFeatures.free);

    features.forEach((feature) => {
      comparison[feature] = {
        free: this.getFeatureLimit('free', feature),
        spark: this.getFeatureLimit('spark', feature),
        sparkplus: this.getFeatureLimit('sparkplus', feature),
        flame: this.getFeatureLimit('flame', feature),
        wildfire: this.getFeatureLimit('wildfire', feature),
        description: this.featureDescriptions[feature],
      };
    });

    return comparison;
  }

  /**
   * Check if user has reached daily limit
   */
  async hasReachedDailyLimit(userId, feature) {
    try {
      const response = await fetch(
        `/api/v1/users/${userId}/usage/${feature}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return false;

      const data = await response.json();
      const tier = await this.getUserTier(userId);
      const limit = this.getFeatureLimit(tier, feature);

      return data.usage >= limit;
    } catch (error) {
      console.error('Error checking daily limit:', error);
      return false;
    }
  }

  /**
   * Get remaining usage for feature
   */
  async getRemainingUsage(userId, feature) {
    try {
      const response = await fetch(
        `/api/v1/users/${userId}/usage/${feature}`,
        {
          headers: {
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
        }
      );

      if (!response.ok) return 0;

      const data = await response.json();
      const tier = await this.getUserTier(userId);
      const limit = this.getFeatureLimit(tier, feature);

      if (limit === Infinity) return Infinity;
      return Math.max(0, limit - data.usage);
    } catch (error) {
      console.error('Error getting remaining usage:', error);
      return 0;
    }
  }

  /**
   * Record feature usage
   */
  async recordUsage(userId, feature, amount = 1) {
    try {
      const response = await fetch(
        `/api/v1/users/${userId}/usage/${feature}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${this.getAuthToken()}`,
          },
          body: JSON.stringify({ amount }),
        }
      );

      return response.ok;
    } catch (error) {
      console.error('Error recording usage:', error);
      return false;
    }
  }

  /**
   * Get paywall message for feature
   */
  getPaywallMessage(feature, currentTier) {
    const messages = {
      matches:
        'Upgrade to see more matches! Get unlimited matches with Spark+ or higher.',
      messages:
        'Upgrade to send more messages! Get unlimited messaging with Spark+ or higher.',
      dailySwipes:
        'Daily limit reached! Upgrade to Spark+ for unlimited daily swipes.',
      videoCalls:
        'Video calling is available with Flame tier and above.',
      rewindFeature:
        'Rewind your last action with Spark+ or higher.',
      exclusiveMatches:
        'Exclusive matches are available with Flame tier and above.',
      prioritySupport:
        'Priority support is available with Spark+ or higher.',
      vipEvents:
        'VIP events access is available with Wildfire tier.',
      advancedFilters:
        'Advanced filters are available with Spark or higher.',
      adFree:
        'Ad-free experience is available with Flame or higher.',
    };

    return (
      messages[feature] ||
      'Upgrade to access this feature.'
    );
  }

  /**
   * Get tier needed for feature
   */
  getTierForFeature(feature) {
    const tiers = ['free', 'spark', 'sparkplus', 'flame', 'wildfire'];

    for (const tier of tiers) {
      if (this.canAccessFeature(tier, feature)) {
        return tier;
      }
    }

    return 'wildfire'; // Default to highest tier
  }

  /**
   * Get auth token from localStorage
   */
  getAuthToken() {
    return localStorage.getItem('authToken') || '';
  }
}

export default new PaywallService();
