/**
 * Firebase Payment Service
 * Tracks payments and subscriptions in Firestore
 */

import {
  collection,
  doc,
  setDoc,
  updateDoc,
  getDocs,
  getDoc,
  query,
  where,
  orderBy,
  limit,
  serverTimestamp,
} from 'firebase/firestore';
import { db } from '../config/firebase';

class FirebasePaymentService {
  async logPayment(uid, paymentData) {
    try {
      const paymentsRef = collection(db, 'payments');

      await setDoc(doc(paymentsRef), {
        userId: uid,
        amount: paymentData.amount,
        currency: paymentData.currency || 'usd',
        status: paymentData.status, // succeeded, pending, failed
        paymentIntentId: paymentData.paymentIntentId,
        description: paymentData.description,
        metadata: paymentData.metadata || {},
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error logging payment:', error);
      throw error;
    }
  }

  async createSubscription(uid, subscriptionData) {
    try {
      const subscriptionsRef = collection(db, 'subscriptions');

      await setDoc(doc(subscriptionsRef), {
        userId: uid,
        stripeSubscriptionId: subscriptionData.stripeSubscriptionId,
        stripePriceId: subscriptionData.stripePriceId,
        tier: subscriptionData.tier,
        status: subscriptionData.status, // active, canceled, past_due
        currentPeriodStart: subscriptionData.currentPeriodStart,
        currentPeriodEnd: subscriptionData.currentPeriodEnd,
        cancelAt: subscriptionData.cancelAt || null,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });

      // Update user tier
      await updateDoc(doc(db, 'users', uid), {
        tier: subscriptionData.tier,
        subscriptionStatus: subscriptionData.status === 'active' ? 'active' : 'inactive',
      });
    } catch (error) {
      console.error('Error creating subscription:', error);
      throw error;
    }
  }

  async updateSubscription(uid, subscriptionData) {
    try {
      const subscriptionsRef = collection(db, 'subscriptions');
      const q = query(
        subscriptionsRef,
        where('userId', '==', uid),
        where('status', 'in', ['active', 'past_due'])
      );

      const snapshot = await getDocs(q);

      if (snapshot.size > 0) {
        const subscriptionDoc = snapshot.docs[0];
        await updateDoc(subscriptionDoc.ref, {
          tier: subscriptionData.tier,
          stripePriceId: subscriptionData.stripePriceId,
          status: subscriptionData.status,
          currentPeriodStart: subscriptionData.currentPeriodStart,
          currentPeriodEnd: subscriptionData.currentPeriodEnd,
          updatedAt: serverTimestamp(),
        });

        // Update user tier
        await updateDoc(doc(db, 'users', uid), {
          tier: subscriptionData.tier,
        });
      }
    } catch (error) {
      console.error('Error updating subscription:', error);
      throw error;
    }
  }

  async cancelSubscription(uid) {
    try {
      const subscriptionsRef = collection(db, 'subscriptions');
      const q = query(
        subscriptionsRef,
        where('userId', '==', uid),
        where('status', 'in', ['active', 'past_due'])
      );

      const snapshot = await getDocs(q);

      if (snapshot.size > 0) {
        const subscriptionDoc = snapshot.docs[0];
        await updateDoc(subscriptionDoc.ref, {
          status: 'canceled',
          updatedAt: serverTimestamp(),
        });

        // Downgrade user to free tier
        await updateDoc(doc(db, 'users', uid), {
          tier: 'free',
          subscriptionStatus: 'inactive',
        });
      }
    } catch (error) {
      console.error('Error canceling subscription:', error);
      throw error;
    }
  }

  async getUserSubscription(uid) {
    try {
      const subscriptionsRef = collection(db, 'subscriptions');
      const q = query(
        subscriptionsRef,
        where('userId', '==', uid),
        orderBy('createdAt', 'desc'),
        limit(1)
      );

      const snapshot = await getDocs(q);

      if (snapshot.size > 0) {
        return {
          id: snapshot.docs[0].id,
          ...snapshot.docs[0].data(),
        };
      }

      return null;
    } catch (error) {
      console.error('Error getting user subscription:', error);
      throw error;
    }
  }

  async getPaymentHistory(uid, pageLimit = 20) {
    try {
      const paymentsRef = collection(db, 'payments');
      const q = query(
        paymentsRef,
        where('userId', '==', uid),
        where('status', '==', 'succeeded'),
        orderBy('createdAt', 'desc'),
        limit(pageLimit)
      );

      const snapshot = await getDocs(q);
      const payments = [];

      snapshot.forEach((doc) => {
        payments.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return payments;
    } catch (error) {
      console.error('Error getting payment history:', error);
      throw error;
    }
  }

  async refundPayment(paymentId, amount = null) {
    try {
      const paymentRef = doc(db, 'payments', paymentId);
      const paymentDoc = await getDoc(paymentRef);

      if (!paymentDoc.exists()) {
        throw new Error('Payment not found');
      }

      await updateDoc(paymentRef, {
        status: 'refunded',
        refundAmount: amount || paymentDoc.data().amount,
        refundedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error refunding payment:', error);
      throw error;
    }
  }

  async logFailedPayment(uid, paymentData) {
    try {
      const paymentsRef = collection(db, 'payments');

      await setDoc(doc(paymentsRef), {
        userId: uid,
        amount: paymentData.amount,
        currency: paymentData.currency || 'usd',
        status: 'failed',
        paymentIntentId: paymentData.paymentIntentId,
        errorMessage: paymentData.errorMessage,
        errorCode: paymentData.errorCode,
        metadata: paymentData.metadata || {},
        createdAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error logging failed payment:', error);
      throw error;
    }
  }

  async getSubscriptionStats(uid) {
    try {
      const subscription = await this.getUserSubscription(uid);
      const payments = await this.getPaymentHistory(uid);

      if (!subscription) {
        return {
          tier: 'free',
          status: 'inactive',
          totalSpent: 0,
          paymentCount: 0,
          nextBillingDate: null,
        };
      }

      const totalSpent = payments.reduce((sum, payment) => sum + payment.amount, 0);

      return {
        tier: subscription.tier,
        status: subscription.status,
        totalSpent: totalSpent / 100,
        paymentCount: payments.length,
        nextBillingDate: subscription.currentPeriodEnd,
        currentPeriodStart: subscription.currentPeriodStart,
        currentPeriodEnd: subscription.currentPeriodEnd,
      };
    } catch (error) {
      console.error('Error getting subscription stats:', error);
      throw error;
    }
  }

  async verifyUserTier(uid, requiredTier) {
    try {
      const userDoc = await getDoc(doc(db, 'users', uid));
      const user = userDoc.data();

      if (!user) {
        return false;
      }

      const tierHierarchy = {
        free: 0,
        spark: 1,
        'spark+': 2,
        flame: 3,
        wildfire: 4,
      };

      const userTierLevel = tierHierarchy[user.tier] || 0;
      const requiredLevel = tierHierarchy[requiredTier] || 0;

      return userTierLevel >= requiredLevel;
    } catch (error) {
      console.error('Error verifying user tier:', error);
      throw error;
    }
  }

  async getTierFeatures(tier) {
    const features = {
      free: {
        checkIns: true,
        meengling: true,
        activities: true,
        messaging: false,
        directMessages: 0,
        advancedFilters: false,
        activityOrganizing: false,
        maxActivityCreates: 0,
      },
      spark: {
        checkIns: true,
        meengling: true,
        activities: true,
        messaging: true,
        directMessages: 5,
        advancedFilters: true,
        activityOrganizing: false,
        maxActivityCreates: 0,
      },
      'spark+': {
        checkIns: true,
        meengling: true,
        activities: true,
        messaging: true,
        directMessages: -1,
        advancedFilters: true,
        activityOrganizing: true,
        maxActivityCreates: 3,
      },
      flame: {
        checkIns: true,
        meengling: true,
        activities: true,
        messaging: true,
        directMessages: -1,
        advancedFilters: true,
        activityOrganizing: true,
        maxActivityCreates: 10,
      },
      wildfire: {
        checkIns: true,
        meengling: true,
        activities: true,
        messaging: true,
        directMessages: -1,
        advancedFilters: true,
        activityOrganizing: true,
        maxActivityCreates: -1,
      },
    };

    return features[tier] || features.free;
  }
}

export default new FirebasePaymentService();
