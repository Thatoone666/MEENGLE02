/**
 * Firebase Authentication Service
 * Handles user sign up, login, logout, and account management
 */

import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  updateProfile,
  sendPasswordResetEmail,
  updateEmail,
  updatePassword,
  deleteUser,
} from 'firebase/auth';
import { auth, db } from '../config/firebase';
import { doc, setDoc, getDoc } from 'firebase/firestore';

class FirebaseAuthService {
  /**
   * Sign up with email and password
   */
  async signUp(email, password, displayName, photoURL = null) {
    try {
      // Create user in Firebase Auth
      const userCredential = await createUserWithEmailAndPassword(
        auth,
        email,
        password
      );

      // Update profile with name and photo
      await updateProfile(userCredential.user, {
        displayName,
        photoURL,
      });

      // Create user document in Firestore
      await setDoc(doc(db, 'users', userCredential.user.uid), {
        uid: userCredential.user.uid,
        email,
        displayName,
        photoURL,
        createdAt: new Date(),
        updatedAt: new Date(),
        tier: 'free',
        subscriptionStatus: 'inactive',
        profile: {
          age: null,
          bio: null,
          location: null,
          interests: [],
          photos: [],
          verified: false,
        },
        settings: {
          notifications: true,
          privateMessages: true,
          showOnline: true,
          showDistance: true,
        },
        stats: {
          profileViews: 0,
          likes: 0,
          matches: 0,
          messages: 0,
        },
      });

      return userCredential.user;
    } catch (error) {
      console.error('Sign up error:', error);
      throw error;
    }
  }

  /**
   * Sign in with email and password
   */
  async signIn(email, password) {
    try {
      const userCredential = await signInWithEmailAndPassword(
        auth,
        email,
        password
      );
      return userCredential.user;
    } catch (error) {
      console.error('Sign in error:', error);
      throw error;
    }
  }

  /**
   * Sign out current user
   */
  async signOut() {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Sign out error:', error);
      throw error;
    }
  }

  /**
   * Get current user
   */
  getCurrentUser() {
    return auth.currentUser;
  }

  /**
   * Listen to auth state changes
   */
  onAuthStateChanged(callback) {
    return onAuthStateChanged(auth, callback);
  }

  /**
   * Get user profile from Firestore
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
      await setDoc(userRef, {
        ...profileData,
        updatedAt: new Date(),
      }, { merge: true });
    } catch (error) {
      console.error('Error updating profile:', error);
      throw error;
    }
  }

  /**
   * Update email
   */
  async updateUserEmail(newEmail) {
    try {
      const user = auth.currentUser;
      if (user) {
        await updateEmail(user, newEmail);
        // Update in Firestore
        await this.updateUserProfile(user.uid, { email: newEmail });
      }
    } catch (error) {
      console.error('Error updating email:', error);
      throw error;
    }
  }

  /**
   * Update password
   */
  async updateUserPassword(newPassword) {
    try {
      const user = auth.currentUser;
      if (user) {
        await updatePassword(user, newPassword);
      }
    } catch (error) {
      console.error('Error updating password:', error);
      throw error;
    }
  }

  /**
   * Send password reset email
   */
  async sendPasswordReset(email) {
    try {
      await sendPasswordResetEmail(auth, email);
    } catch (error) {
      console.error('Error sending reset email:', error);
      throw error;
    }
  }

  /**
   * Delete user account
   */
  async deleteUserAccount(uid) {
    try {
      const user = auth.currentUser;
      if (user) {
        // Delete user document from Firestore
        await this.deleteUserFromFirestore(uid);
        // Delete from Firebase Auth
        await deleteUser(user);
      }
    } catch (error) {
      console.error('Error deleting account:', error);
      throw error;
    }
  }

  /**
   * Delete user document from Firestore
   */
  async deleteUserFromFirestore(uid) {
    try {
      // Set user as deleted (soft delete)
      await setDoc(doc(db, 'users', uid), {
        deleted: true,
        deletedAt: new Date(),
      }, { merge: true });
    } catch (error) {
      console.error('Error deleting user from Firestore:', error);
      throw error;
    }
  }
}

export default new FirebaseAuthService();
