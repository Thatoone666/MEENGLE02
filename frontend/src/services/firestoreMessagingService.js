/**
 * Firestore Messaging Service
 * Manages real-time messaging between matched users
 */

import {
  collection,
  doc,
  setDoc,
  getDocs,
  query,
  where,
  orderBy,
  limit,
  onSnapshot,
  updateDoc,
  serverTimestamp,
  arrayUnion,
  Timestamp,
} from 'firebase/firestore';
import { db } from '../config/firebase';

class FirestoreMessagingService {
  /**
   * Send message
   */
  async sendMessage(matchId, fromUid, toUid, messageData) {
    try {
      const messagesRef = collection(db, `matches/${matchId}/messages`);

      await setDoc(doc(messagesRef), {
        fromUid,
        toUid,
        content: messageData.content,
        type: messageData.type || 'text', // text, image, activity-invite
        metadata: messageData.metadata || {},
        sentAt: serverTimestamp(),
        readAt: null,
        status: 'sent', // sent, delivered, read
      });

      // Update match document with last message
      const matchRef = doc(db, 'matches', matchId);
      await updateDoc(matchRef, {
        lastMessage: messageData.content,
        lastMessageTime: serverTimestamp(),
        [`unreadCount.${toUid}`]: arrayUnion(1),
        updatedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error sending message:', error);
      throw error;
    }
  }

  /**
   * Get conversation messages
   */
  async getConversation(matchId, pageLimit = 50) {
    try {
      const messagesRef = collection(db, `matches/${matchId}/messages`);
      const q = query(
        messagesRef,
        orderBy('sentAt', 'desc'),
        limit(pageLimit)
      );

      const snapshot = await getDocs(q);
      const messages = [];

      snapshot.forEach((doc) => {
        messages.push({
          id: doc.id,
          ...doc.data(),
        });
      });

      return messages.reverse(); // Oldest first
    } catch (error) {
      console.error('Error getting conversation:', error);
      throw error;
    }
  }

  /**
   * Listen to conversation in real-time
   */
  onConversationUpdate(matchId, callback) {
    const messagesRef = collection(db, `matches/${matchId}/messages`);
    const q = query(messagesRef, orderBy('sentAt', 'asc'));

    return onSnapshot(q, (snapshot) => {
      const messages = [];
      snapshot.forEach((doc) => {
        messages.push({
          id: doc.id,
          ...doc.data(),
        });
      });
      callback(messages);
    });
  }

  /**
   * Mark message as read
   */
  async markMessageAsRead(matchId, messageId, readBy) {
    try {
      const messageRef = doc(
        db,
        `matches/${matchId}/messages`,
        messageId
      );

      await updateDoc(messageRef, {
        readAt: serverTimestamp(),
        status: 'read',
      });

      // Update match unread count
      const matchRef = doc(db, 'matches', matchId);
      const matchDoc = await getDocs(
        query(
          collection(db, 'matches'),
          where('__name__', '==', matchId)
        )
      );

      if (matchDoc.size > 0) {
        const match = matchDoc.docs[0].data();
        const unreadCount = match.unreadCount[readBy] || 0;
        await updateDoc(matchRef, {
          [`unreadCount.${readBy}`]: Math.max(0, unreadCount - 1),
        });
      }
    } catch (error) {
      console.error('Error marking message as read:', error);
      throw error;
    }
  }

  /**
   * Get unread message count
   */
  async getUnreadCount(uid) {
    try {
      const matchesRef = collection(db, 'matches');
      const q = query(
        matchesRef,
        where('users', 'array-contains', uid)
      );

      const snapshot = await getDocs(q);
      let totalUnread = 0;

      snapshot.forEach((doc) => {
        const match = doc.data();
        totalUnread += match.unreadCount[uid] || 0;
      });

      return totalUnread;
    } catch (error) {
      console.error('Error getting unread count:', error);
      throw error;
    }
  }

  /**
   * Delete message (soft delete)
   */
  async deleteMessage(matchId, messageId) {
    try {
      const messageRef = doc(
        db,
        `matches/${matchId}/messages`,
        messageId
      );

      await updateDoc(messageRef, {
        content: '[Deleted]',
        type: 'deleted',
        deletedAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error deleting message:', error);
      throw error;
    }
  }

  /**
   * Send activity invitation via message
   */
  async sendActivityInvite(matchId, fromUid, toUid, activityData) {
    try {
      await this.sendMessage(matchId, fromUid, toUid, {
        content: `Invited you to: ${activityData.title}`,
        type: 'activity-invite',
        metadata: {
          activityId: activityData.id,
          activityTitle: activityData.title,
          activityTime: activityData.time,
          activityCategory: activityData.category,
        },
      });
    } catch (error) {
      console.error('Error sending activity invite:', error);
      throw error;
    }
  }

  /**
   * Format message timestamp
   */
  formatMessageTime(timestamp) {
    if (!timestamp) return '';

    const date =
      timestamp instanceof Timestamp
        ? timestamp.toDate()
        : new Date(timestamp);
    const now = new Date();

    // Same day
    if (date.toDateString() === now.toDateString()) {
      return date.toLocaleTimeString([], {
        hour: '2-digit',
        minute: '2-digit',
      });
    }

    // Yesterday
    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday';
    }

    // Same year
    if (date.getFullYear() === now.getFullYear()) {
      return date.toLocaleDateString([], {
        month: 'short',
        day: 'numeric',
      });
    }

    // Different year
    return date.toLocaleDateString([], {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  }

  /**
   * Listen to unread count changes
   */
  onUnreadCountChange(uid, callback) {
    const matchesRef = collection(db, 'matches');
    const q = query(
      matchesRef,
      where('users', 'array-contains', uid)
    );

    return onSnapshot(q, (snapshot) => {
      let totalUnread = 0;
      snapshot.forEach((doc) => {
        const match = doc.data();
        totalUnread += match.unreadCount[uid] || 0;
      });
      callback(totalUnread);
    });
  }
}

export default new FirestoreMessagingService();
