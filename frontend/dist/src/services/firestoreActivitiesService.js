/**
 * Firestore Activities Service
 * Manages activity creation, discovery, participation, and ratings
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
  arrayUnion,
  arrayRemove,
  increment,
} from 'firebase/firestore';
import { db } from '../config/firebase';

class FirestoreActivitiesService {
  static CATEGORIES = [
    'Sports',
    'Gaming',
    'Fitness',
    'Art & Culture',
    'Food & Drink',
    'Music & Entertainment',
    'Outdoor Adventure',
    'Water Sports',
    'Nightlife',
    'Movies & Theater',
    'Museums & Galleries',
    'Workshops & Classes',
    'Networking',
    'Photography',
    'Volunteering',
    'Travel',
    'Wellness',
    'Technology',
    'Business',
    'Social',
  ];

  static SKILL_LEVELS = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];

  async createActivity(uid, activityData) {
    try {
      const activitiesRef = collection(db, 'activities');

      const activityDoc = await setDoc(doc(activitiesRef), {
        organizerId: uid,
        title: activityData.title,
        category: activityData.category,
        description: activityData.description,
        location: activityData.location,
        latitude: activityData.latitude,
        longitude: activityData.longitude,
        time: activityData.time,
        duration: activityData.duration,
        cost: activityData.cost || 0,
        maxParticipants: activityData.maxParticipants,
        skillLevel: activityData.skillLevel,
        participants: [uid],
        participantCount: 1,
        photos: activityData.photos || [],
        description: activityData.description,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        status: 'active',
        rating: 0,
        ratingCount: 0,
        tags: activityData.tags || [],
        interested: [],
      });

      return activityDoc;
    } catch (error) {
      console.error('Error creating activity:', error);
      throw error;
    }
  }

  async getActivity(activityId) {
    try {
      const activityDoc = await getDoc(doc(db, 'activities', activityId));
      return activityDoc.exists() ? { id: activityDoc.id, ...activityDoc.data() } : null;
    } catch (error) {
      console.error('Error getting activity:', error);
      throw error;
    }
  }

  async getNearbyActivities(latitude, longitude, radiusKm = 25, categoryFilter = null) {
    try {
      const activitiesRef = collection(db, 'activities');
      let q;

      if (categoryFilter) {
        q = query(
          activitiesRef,
          where('category', '==', categoryFilter),
          where('status', '==', 'active'),
          orderBy('createdAt', 'desc'),
          limit(50)
        );
      } else {
        q = query(
          activitiesRef,
          where('status', '==', 'active'),
          orderBy('createdAt', 'desc'),
          limit(50)
        );
      }

      const snapshot = await getDocs(q);
      const activities = [];

      snapshot.forEach((doc) => {
        const activity = doc.data();
        const distance = this.calculateDistance(
          latitude,
          longitude,
          activity.latitude,
          activity.longitude
        );

        if (distance <= radiusKm) {
          activities.push({
            id: doc.id,
            ...activity,
            distance,
          });
        }
      });

      return activities.sort((a, b) => a.distance - b.distance);
    } catch (error) {
      console.error('Error getting nearby activities:', error);
      throw error;
    }
  }

  async getActivitiesByCategory(category, limit = 20) {
    try {
      const activitiesRef = collection(db, 'activities');
      const q = query(
        activitiesRef,
        where('category', '==', category),
        where('status', '==', 'active'),
        orderBy('createdAt', 'desc'),
        limit
      );

      const snapshot = await getDocs(q);
      const activities = [];

      snapshot.forEach((doc) => {
        activities.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return activities;
    } catch (error) {
      console.error('Error getting activities by category:', error);
      throw error;
    }
  }

  async getUserActivities(uid) {
    try {
      const activitiesRef = collection(db, 'activities');
      const q = query(
        activitiesRef,
        where('organizerId', '==', uid),
        orderBy('createdAt', 'desc')
      );

      const snapshot = await getDocs(q);
      const activities = [];

      snapshot.forEach((doc) => {
        activities.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return activities;
    } catch (error) {
      console.error('Error getting user activities:', error);
      throw error;
    }
  }

  async getParticipatingActivities(uid) {
    try {
      const activitiesRef = collection(db, 'activities');
      const q = query(
        activitiesRef,
        where('participants', 'array-contains', uid),
        orderBy('time', 'asc')
      );

      const snapshot = await getDocs(q);
      const activities = [];

      snapshot.forEach((doc) => {
        activities.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return activities;
    } catch (error) {
      console.error('Error getting participating activities:', error);
      throw error;
    }
  }

  async joinActivity(activityId, uid) {
    try {
      const activityRef = doc(db, 'activities', activityId);
      const activityDoc = await getDoc(activityRef);

      if (!activityDoc.exists()) {
        throw new Error('Activity not found');
      }

      const activity = activityDoc.data();

      if (activity.participants.includes(uid)) {
        throw new Error('Already participating');
      }

      if (activity.participantCount >= activity.maxParticipants) {
        throw new Error('Activity is full');
      }

      await updateDoc(activityRef, {
        participants: arrayUnion(uid),
        participantCount: increment(1),
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error joining activity:', error);
      throw error;
    }
  }

  async leaveActivity(activityId, uid) {
    try {
      const activityRef = doc(db, 'activities', activityId);
      await updateDoc(activityRef, {
        participants: arrayRemove(uid),
        participantCount: increment(-1),
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error leaving activity:', error);
      throw error;
    }
  }

  async rateActivity(activityId, uid, rating, review = '') {
    try {
      const ratingRef = doc(db, `activities/${activityId}/ratings`, uid);
      
      await setDoc(ratingRef, {
        userId: uid,
        rating,
        review,
        createdAt: serverTimestamp(),
      });

      const activityRef = doc(db, 'activities', activityId);
      const activityDoc = await getDoc(activityRef);
      const activity = activityDoc.data();

      const newRating = 
        (activity.rating * activity.ratingCount + rating) / (activity.ratingCount + 1);

      await updateDoc(activityRef, {
        rating: newRating,
        ratingCount: increment(1),
      });
    } catch (error) {
      console.error('Error rating activity:', error);
      throw error;
    }
  }

  async updateActivity(activityId, updateData) {
    try {
      const activityRef = doc(db, 'activities', activityId);
      await updateDoc(activityRef, {
        ...updateData,
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error updating activity:', error);
      throw error;
    }
  }

  async deleteActivity(activityId) {
    try {
      const activityRef = doc(db, 'activities', activityId);
      await updateDoc(activityRef, {
        status: 'cancelled',
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error deleting activity:', error);
      throw error;
    }
  }

  async showInterest(activityId, uid) {
    try {
      const activityRef = doc(db, 'activities', activityId);
      const activityDoc = await getDoc(activityRef);

      if (activityDoc.exists()) {
        const interested = activityDoc.data().interested || [];

        if (!interested.includes(uid)) {
          await updateDoc(activityRef, {
            interested: arrayUnion(uid),
          });
        }
      }
    } catch (error) {
      console.error('Error showing interest:', error);
      throw error;
    }
  }

  async removeInterest(activityId, uid) {
    try {
      const activityRef = doc(db, 'activities', activityId);
      await updateDoc(activityRef, {
        interested: arrayRemove(uid),
      });
    } catch (error) {
      console.error('Error removing interest:', error);
      throw error;
    }
  }

  onNearbyActivities(latitude, longitude, callback, radiusKm = 25) {
    const activitiesRef = collection(db, 'activities');
    const q = query(
      activitiesRef,
      where('status', '==', 'active'),
      orderBy('createdAt', 'desc'),
      limit(50)
    );

    return onSnapshot(q, (snapshot) => {
      const activities = [];

      snapshot.forEach((doc) => {
        const activity = doc.data();
        const distance = this.calculateDistance(
          latitude,
          longitude,
          activity.latitude,
          activity.longitude
        );

        if (distance <= radiusKm) {
          activities.push({
            id: doc.id,
            ...activity,
            distance,
          });
        }
      });

      callback(activities.sort((a, b) => a.distance - b.distance));
    });
  }

  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
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

  toRad(deg) {
    return deg * (Math.PI / 180);
  }

  async getActivityRatings(activityId) {
    try {
      const ratingsRef = collection(db, `activities/${activityId}/ratings`);
      const snapshot = await getDocs(ratingsRef);
      const ratings = [];

      snapshot.forEach((doc) => {
        ratings.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return ratings;
    } catch (error) {
      console.error('Error getting activity ratings:', error);
      throw error;
    }
  }
}

export default new FirestoreActivitiesService();
