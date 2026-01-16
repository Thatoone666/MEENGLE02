/**
 * Firestore Users Service
 * Manages user profiles, data, and relationships
 */

import {
  collection,
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  getDocs,
  limit,
  orderBy,
  startAfter,
  onSnapshot,
} from 'firebase/firestore';
import { db } from '../config/firebase';

class FirestoreUsersService {
  /**
   * Create user profile document
   */
  async createUserProfile(uid, profileData) {
    try {
      const userRef = doc(db, 'users', uid);
      await setDoc(userRef, {
        uid,
        email: profileData.email,
        displayName: profileData.displayName,
        photoURL: profileData.photoURL,
        createdAt: new Date(),
        updatedAt: new Date(),
        tier: 'free',
        subscriptionStatus: 'inactive',
        profile: {
          age: null,
          bio: null,
          location: null,
          latitude: null,
          longitude: null,
          interests: [],
          photos: [],
          verified: false,
          rating: 0,
          reviewCount: 0,
        },
        settings: {
          notifications: true,
          privateMessages: true,
          showOnline: true,
          showDistance: true,
          discoverable: true,
        },
        stats: {
          profileViews: 0,
          likes: 0,
          matches: 0,
          messages: 0,
          checkIns: 0,
          activities: 0,
        },
        blockedUsers: [],
        reportedUsers: [],
      });

      return userRef;
    } catch (error) {
      console.error('Error creating user profile:', error);
      throw error;
    }
  }

  /**
   * Get user profile
   */
  async getUserProfile(uid) {
    try {
      const userDoc = await getDoc(doc(db, 'users', uid));
      return userDoc.exists() ? userDoc.data() : null;
    } catch (error) {
      console.error('Error getting user profile:', error);
      throw error;
    }
  }

  /**
   * Update user profile
   */
  async updateUserProfile(uid, profileData) {
    try {
      const userRef = doc(db, 'users', uid);
      await updateDoc(userRef, {
        ...profileData,
        updatedAt: new Date(),
      });
    } catch (error) {
      console.error('Error updating user profile:', error);
      throw error;
    }
  }

  /**
   * Update user location
   */
  async updateUserLocation(uid, latitude, longitude) {
    try {
      const userRef = doc(db, 'users', uid);
      await updateDoc(userRef, {
        'profile.latitude': latitude,
        'profile.longitude': longitude,
        updatedAt: new Date(),
      });
    } catch (error) {
      console.error('Error updating user location:', error);
      throw error;
    }
  }

  /**
   * Get users by location (nearby)
   */
  async getNearbyUsers(
    latitude,
    longitude,
    radiusKm = 50,
    limit = 20
  ) {
    try {
      // Simple query - in production, use GeoHash or similar
      const usersRef = collection(db, 'users');
      const q = query(
        usersRef,
        where('profile.discoverable', '==', true),
        limit
      );

      const snapshot = await getDocs(q);
      const users = [];

      snapshot.forEach((doc) => {
        const user = doc.data();
        const distance = this.calculateDistance(
          latitude,
          longitude,
          user.profile.latitude,
          user.profile.longitude
        );

        if (distance <= radiusKm) {
          users.push({
            ...user,
            distance,
          });
        }
      });

      return users.sort((a, b) => a.distance - b.distance);
    } catch (error) {
      console.error('Error getting nearby users:', error);
      throw error;
    }
  }

  /**
   * Calculate distance between two coordinates (Haversine formula)
   */
  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) *
        Math.cos(this.toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  /**
   * Convert degrees to radians
   */
  toRad(deg) {
    return deg * (Math.PI / 180);
  }

  /**
   * Block user
   */
  async blockUser(uid, blockedUid) {
    try {
      const userRef = doc(db, 'users', uid);
      const userDoc = await getDoc(userRef);
      const blockedUsers = userDoc.data().blockedUsers || [];

      if (!blockedUsers.includes(blockedUid)) {
        blockedUsers.push(blockedUid);
        await updateDoc(userRef, {
          blockedUsers,
          updatedAt: new Date(),
        });
      }
    } catch (error) {
      console.error('Error blocking user:', error);
      throw error;
    }
  }

  /**
   * Unblock user
   */
  async unblockUser(uid, blockedUid) {
    try {
      const userRef = doc(db, 'users', uid);
      const userDoc = await getDoc(userRef);
      const blockedUsers = (userDoc.data().blockedUsers || []).filter(
        (id) => id !== blockedUid
      );

      await updateDoc(userRef, {
        blockedUsers,
        updatedAt: new Date(),
      });
    } catch (error) {
      console.error('Error unblocking user:', error);
      throw error;
    }
  }

  /**
   * Report user
   */
  async reportUser(uid, reportedUid, reason) {
    try {
      // Create report document
      const reportsRef = collection(db, 'reports');
      await setDoc(doc(reportsRef), {
        reportedBy: uid,
        reportedUser: reportedUid,
        reason,
        createdAt: new Date(),
        status: 'pending',
      });

      // Add to reported users list
      const userRef = doc(db, 'users', uid);
      const userDoc = await getDoc(userRef);
      const reportedUsers = userDoc.data().reportedUsers || [];

      if (!reportedUsers.includes(reportedUid)) {
        reportedUsers.push(reportedUid);
        await updateDoc(userRef, {
          reportedUsers,
          updatedAt: new Date(),
        });
      }
    } catch (error) {
      console.error('Error reporting user:', error);
      throw error;
    }
  }

  /**
   * Listen to user profile changes
   */
  onUserProfileChange(uid, callback) {
    const userRef = doc(db, 'users', uid);
    return onSnapshot(userRef, (doc) => {
      callback(doc.exists() ? doc.data() : null);
    });
  }

  /**
   * Update user tier
   */
  async updateUserTier(uid, tier) {
    try {
      const userRef = doc(db, 'users', uid);
      await updateDoc(userRef, {
        tier,
        subscriptionStatus: tier === 'free' ? 'inactive' : 'active',
        updatedAt: new Date(),
      });
    } catch (error) {
      console.error('Error updating user tier:', error);
      throw error;
    }
  }

  /**
   * Increment user stat
   */
  async incrementUserStat(uid, statKey) {
    try {
      const userRef = doc(db, 'users', uid);
      const userDoc = await getDoc(userRef);
      const currentValue = userDoc.data().stats[statKey] || 0;

      await updateDoc(userRef, {
        [`stats.${statKey}`]: currentValue + 1,
        updatedAt: new Date(),
      });
    } catch (error) {
      console.error('Error incrementing user stat:', error);
      throw error;
    }
  }
}

export default new FirestoreUsersService();
