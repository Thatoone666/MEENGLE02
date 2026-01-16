/**
 * Firestore Meengling Service
 * Manages profile swiping, likes, and matches
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
  orderBy,
  limit,
  onSnapshot,
  arrayUnion,
  arrayRemove,
} from 'firebase/firestore';
import { db } from '../config/firebase';
import firestoreUsersService from './firestoreUsersService';

class FirestoreMeenglingService {
  /**
   * Create or update swipe record
   */
  async swipe(uid, targetUid, action) {
    try {
      const swipeRef = doc(
        db,
        `users/${uid}/swipes`,
        targetUid
      );

      await setDoc(swipeRef, {
        targetUid,
        action, // 'like' or 'pass'
        createdAt: new Date(),
      });

      // If like, check for mutual match
      if (action === 'like') {
        await this.checkForMatch(uid, targetUid);
      }
    } catch (error) {
      console.error('Error recording swipe:', error);
      throw error;
    }
  }

  /**
   * Check if swipe creates a match
   */
  async checkForMatch(uid, targetUid) {
    try {
      // Check if target has liked user
      const targetSwipeRef = doc(
        db,
        `users/${targetUid}/swipes`,
        uid
      );
      const targetSwipeDoc = await getDoc(targetSwipeRef);

      if (
        targetSwipeDoc.exists() &&
        targetSwipeDoc.data().action === 'like'
      ) {
        // Create match
        await this.createMatch(uid, targetUid);
      }
    } catch (error) {
      console.error('Error checking for match:', error);
      throw error;
    }
  }

  /**
   * Create a match between two users
   */
  async createMatch(uid1, uid2) {
    try {
      const matchId = [uid1, uid2].sort().join('_');
      const matchRef = doc(db, 'matches', matchId);

      const matchDoc = await getDoc(matchRef);

      // Only create if match doesn't already exist
      if (!matchDoc.exists()) {
        await setDoc(matchRef, {
          users: [uid1, uid2],
          createdAt: new Date(),
          updatedAt: new Date(),
          lastMessage: null,
          lastMessageTime: null,
          unreadCount: {
            [uid1]: 0,
            [uid2]: 0,
          },
          status: 'active',
        });

        // Increment match count for both users
        await firestoreUsersService.incrementUserStat(uid1, 'matches');
        await firestoreUsersService.incrementUserStat(uid2, 'matches');
      }

      return matchId;
    } catch (error) {
      console.error('Error creating match:', error);
      throw error;
    }
  }

  /**
   * Get user's matches
   */
  async getUserMatches(uid) {
    try {
      const matchesRef = collection(db, 'matches');
      const q = query(
        matchesRef,
        where('users', 'array-contains', uid),
        where('status', '==', 'active'),
        orderBy('updatedAt', 'desc')
      );

      const snapshot = await getDocs(q);
      const matches = [];

      for (const matchDoc of snapshot.docs) {
        const matchData = matchDoc.data();
        const otherUid = matchData.users.find((u) => u !== uid);
        const userProfile = await firestoreUsersService.getUserProfile(
          otherUid
        );

        matches.push({
          id: matchDoc.id,
          ...matchData,
          user: userProfile,
        });
      }

      return matches;
    } catch (error) {
      console.error('Error getting user matches:', error);
      throw error;
    }
  }

  /**
   * Get single match details
   */
  async getMatch(matchId) {
    try {
      const matchDoc = await getDoc(doc(db, 'matches', matchId));
      return matchDoc.exists() ? matchDoc.data() : null;
    } catch (error) {
      console.error('Error getting match:', error);
      throw error;
    }
  }

  /**
   * Get swipes for user (profiles they've swiped)
   */
  async getUserSwipes(uid) {
    try {
      const swipesRef = collection(db, `users/${uid}/swipes`);
      const snapshot = await getDocs(swipesRef);

      const swipes = [];
      snapshot.forEach((doc) => {
        swipes.push({
          targetUid: doc.id,
          ...doc.data(),
        });
      });

      return swipes;
    } catch (error) {
      console.error('Error getting user swipes:', error);
      throw error;
    }
  }

  /**
   * Get profiles to discover (excluding swiped/blocked)
   */
  async getDiscoveryProfiles(uid, latitude, longitude, limit = 10) {
    try {
      // Get user's swipes and blocks
      const swipes = await this.getUserSwipes(uid);
      const userProfile = await firestoreUsersService.getUserProfile(uid);
      const swipedUids = swipes.map((s) => s.targetUid);
      const blockedUids = userProfile.blockedUsers || [];
      const excludeUids = [uid, ...swipedUids, ...blockedUids];

      // Get nearby users
      let nearbyUsers = await firestoreUsersService.getNearbyUsers(
        latitude,
        longitude,
        50, // 50km radius
        limit * 2 // Get extra in case some need to be filtered
      );

      // Filter out swiped/blocked users
      nearbyUsers = nearbyUsers.filter(
        (user) => !excludeUids.includes(user.uid)
      );

      // Return top matches based on interests
      return this.scoreProfileMatches(userProfile, nearbyUsers).slice(
        0,
        limit
      );
    } catch (error) {
      console.error('Error getting discovery profiles:', error);
      throw error;
    }
  }

  /**
   * Score profile matches based on interests
   */
  scoreProfileMatches(userProfile, candidates) {
    return candidates
      .map((candidate) => {
        let score = 0;

        // Interest matching
        const commonInterests = userProfile.profile.interests.filter(
          (interest) =>
            candidate.profile.interests.includes(interest)
        );
        score += commonInterests.length * 10;

        // Age preference (assume 18-65 range, prefer closer)
        const ageDifference = Math.abs(
          userProfile.profile.age - candidate.profile.age
        );
        score += Math.max(0, 20 - ageDifference);

        // Distance preference (closer is better)
        score += Math.max(0, 20 - candidate.distance);

        // Profile completeness bonus
        if (candidate.profile.verified) score += 5;
        if (candidate.profile.photos.length > 0) score += 3;

        return {
          ...candidate,
          matchScore: score,
        };
      })
      .sort((a, b) => b.matchScore - a.matchScore);
  }

  /**
   * Listen to match updates
   */
  onMatchUpdates(matchId, callback) {
    const matchRef = doc(db, 'matches', matchId);
    return onSnapshot(matchRef, (doc) => {
      callback(doc.exists() ? doc.data() : null);
    });
  }

  /**
   * Unmatch users
   */
  async unmatch(matchId) {
    try {
      const matchRef = doc(db, 'matches', matchId);
      await updateDoc(matchRef, {
        status: 'inactive',
        updatedAt: new Date(),
      });
    } catch (error) {
      console.error('Error unmatching:', error);
      throw error;
    }
  }
}

export default new FirestoreMeenglingService();
