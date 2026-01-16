/**
 * Firestore Check-In Service
 * Manages real-time check-ins and location-based social discovery
 */

import {
  collection,
  doc,
  setDoc,
  updateDoc,
  deleteDoc,
  getDocs,
  getDoc,
  query,
  where,
  orderBy,
  limit,
  onSnapshot,
  serverTimestamp,
  Timestamp,
} from 'firebase/firestore';
import { db } from '../config/firebase';

class FirestoreCheckInService {
  /**
   * Check-in types
   */
  static CHECKIN_TYPES = [
    'Hotel',
    'Restaurant',
    'Club',
    'Beach',
    'Park',
    'Bar',
    'Cafe',
    'Gym',
    'Theater',
    'Museum',
    'Shopping',
    'Concert',
    'Sports',
    'Gaming',
    'Hangout',
  ];

  /**
   * Status options
   */
  static STATUS_OPTIONS = [
    'Looking',
    'Chilling',
    'Party',
    'Gaming',
    'Studying',
  ];

  /**
   * Visibility levels
   */
  static VISIBILITY_LEVELS = ['Public', 'Friends', 'Private', 'Hidden'];

  /**
   * Create a check-in
   */
  async createCheckIn(uid, checkInData) {
    try {
      const checkInsRef = collection(db, 'checkIns');

      const checkInDoc = await setDoc(doc(checkInsRef), {
        userId: uid,
        type: checkInData.type,
        location: checkInData.location,
        latitude: checkInData.latitude,
        longitude: checkInData.longitude,
        status: checkInData.status,
        visibility: checkInData.visibility || 'Public',
        bio: checkInData.bio || '',
        createdAt: serverTimestamp(),
        expiresAt: this.getExpirationTime(checkInData.duration),
        likes: 0,
        comments: 0,
        views: 0,
        interested: [],
      });

      return checkInDoc;
    } catch (error) {
      console.error('Error creating check-in:', error);
      throw error;
    }
  }

  /**
   * Get check-in details
   */
  async getCheckIn(checkInId) {
    try {
      const checkInDoc = await getDoc(doc(db, 'checkIns', checkInId));
      return checkInDoc.exists() ? checkInDoc.data() : null;
    } catch (error) {
      console.error('Error getting check-in:', error);
      throw error;
    }
  }

  /**
   * Get nearby check-ins
   */
  async getNearbyCheckIns(latitude, longitude, radiusKm = 5) {
    try {
      const checkInsRef = collection(db, 'checkIns');
      const q = query(
        checkInsRef,
        where('visibility', 'in', ['Public', 'Friends']),
        orderBy('createdAt', 'desc'),
        limit(50)
      );

      const snapshot = await getDocs(q);
      const checkIns = [];

      snapshot.forEach((doc) => {
        const checkIn = doc.data();
        const distance = this.calculateDistance(
          latitude,
          longitude,
          checkIn.latitude,
          checkIn.longitude
        );

        if (distance <= radiusKm) {
          checkIns.push({
            id: doc.id,
            ...checkIn,
            distance,
          });
        }
      });

      return checkIns.sort((a, b) => a.distance - b.distance);
    } catch (error) {
      console.error('Error getting nearby check-ins:', error);
      throw error;
    }
  }

  /**
   * Get user's check-ins
   */
  async getUserCheckIns(uid) {
    try {
      const checkInsRef = collection(db, 'checkIns');
      const q = query(
        checkInsRef,
        where('userId', '==', uid),
        orderBy('createdAt', 'desc')
      );

      const snapshot = await getDocs(q);
      const checkIns = [];

      snapshot.forEach((doc) => {
        checkIns.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return checkIns;
    } catch (error) {
      console.error('Error getting user check-ins:', error);
      throw error;
    }
  }

  /**
   * Update check-in
   */
  async updateCheckIn(checkInId, updateData) {
    try {
      const checkInRef = doc(db, 'checkIns', checkInId);
      await updateDoc(checkInRef, {
        ...updateData,
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error updating check-in:', error);
      throw error;
    }
  }

  /**
   * Delete check-in
   */
  async deleteCheckIn(checkInId) {
    try {
      const checkInRef = doc(db, 'checkIns', checkInId);
      await deleteDoc(checkInRef);
    } catch (error) {
      console.error('Error deleting check-in:', error);
      throw error;
    }
  }

  /**
   * Like check-in
   */
  async likeCheckIn(checkInId) {
    try {
      const checkInRef = doc(db, 'checkIns', checkInId);
      const checkInDoc = await getDoc(checkInRef);

      if (checkInDoc.exists()) {
        const currentLikes = checkInDoc.data().likes || 0;
        await updateDoc(checkInRef, {
          likes: currentLikes + 1,
        });
      }
    } catch (error) {
      console.error('Error liking check-in:', error);
      throw error;
    }
  }

  /**
   * Show interest in check-in
   */
  async showInterest(checkInId, uid) {
    try {
      const checkInRef = doc(db, 'checkIns', checkInId);
      const checkInDoc = await getDoc(checkInRef);

      if (checkInDoc.exists()) {
        const interested = checkInDoc.data().interested || [];

        if (!interested.includes(uid)) {
          interested.push(uid);
          await updateDoc(checkInRef, {
            interested,
          });
        }
      }
    } catch (error) {
      console.error('Error showing interest:', error);
      throw error;
    }
  }

  /**
   * Listen to nearby check-ins in real-time
   */
  onNearbyCheckIns(latitude, longitude, callback) {
    const checkInsRef = collection(db, 'checkIns');
    const q = query(
      checkInsRef,
      where('visibility', 'in', ['Public', 'Friends']),
      orderBy('createdAt', 'desc'),
      limit(50)
    );

    return onSnapshot(q, (snapshot) => {
      const checkIns = [];

      snapshot.forEach((doc) => {
        const checkIn = doc.data();
        const distance = this.calculateDistance(
          latitude,
          longitude,
          checkIn.latitude,
          checkIn.longitude
        );

        if (distance <= 5) {
          checkIns.push({
            id: doc.id,
            ...checkIn,
            distance,
          });
        }
      });

      callback(checkIns.sort((a, b) => a.distance - b.distance));
    });
  }

  /**
   * Calculate distance between coordinates
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
   * Calculate check-in expiration time
   */
  getExpirationTime(durationHours = 4) {
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + durationHours);
    return Timestamp.fromDate(expiresAt);
  }

  /**
   * Clean up expired check-ins
   */
  async cleanupExpiredCheckIns() {
    try {
      const checkInsRef = collection(db, 'checkIns');
      const q = query(
        checkInsRef,
        where('expiresAt', '<', Timestamp.now())
      );

      const snapshot = await getDocs(q);
      const batch = [];

      snapshot.forEach((doc) => {
        batch.push(deleteDoc(doc.ref));
      });

      await Promise.all(batch);
    } catch (error) {
      console.error('Error cleaning up expired check-ins:', error);
      throw error;
    }
  }
}

export default new FirestoreCheckInService();
