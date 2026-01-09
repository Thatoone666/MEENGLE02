/**
 * Firebase Storage Service
 * Manages file uploads, optimization, and downloads
 */

import { storage } from '../config/firebase';
import {
  ref,
  uploadBytes,
  uploadBytesResumable,
  getDownloadURL,
  deleteObject,
  listAll,
} from 'firebase/storage';

class FirebaseStorageService {
  /**
   * Upload user profile photo
   */
  async uploadProfilePhoto(uid, file) {
    try {
      const timestamp = Date.now();
      const fileRef = ref(storage, `users/${uid}/profile/${timestamp}`);

      const snapshot = await uploadBytes(fileRef, file, {
        contentType: file.type,
        customMetadata: {
          uploadedAt: new Date().toISOString(),
        },
      });

      const downloadURL = await getDownloadURL(snapshot.ref);
      return downloadURL;
    } catch (error) {
      console.error('Error uploading profile photo:', error);
      throw error;
    }
  }

  /**
   * Upload with progress tracking
   */
  uploadProfilePhotoWithProgress(uid, file, onProgress) {
    const timestamp = Date.now();
    const fileRef = ref(storage, `users/${uid}/profile/${timestamp}`);

    const uploadTask = uploadBytesResumable(fileRef, file, {
      contentType: file.type,
      customMetadata: {
        uploadedAt: new Date().toISOString(),
      },
    });

    uploadTask.on(
      'state_changed',
      (snapshot) => {
        const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        onProgress(progress);
      },
      (error) => {
        console.error('Error uploading file:', error);
      }
    );

    return uploadTask;
  }

  /**
   * Upload activity photo
   */
  async uploadActivityPhoto(activityId, file) {
    try {
      const timestamp = Date.now();
      const fileRef = ref(storage, `activities/${activityId}/${timestamp}`);

      const snapshot = await uploadBytes(fileRef, file, {
        contentType: file.type,
      });

      const downloadURL = await getDownloadURL(snapshot.ref);
      return downloadURL;
    } catch (error) {
      console.error('Error uploading activity photo:', error);
      throw error;
    }
  }

  /**
   * Upload check-in photo
   */
  async uploadCheckInPhoto(checkInId, file) {
    try {
      const timestamp = Date.now();
      const fileRef = ref(storage, `checkIns/${checkInId}/${timestamp}`);

      const snapshot = await uploadBytes(fileRef, file, {
        contentType: file.type,
      });

      const downloadURL = await getDownloadURL(snapshot.ref);
      return downloadURL;
    } catch (error) {
      console.error('Error uploading check-in photo:', error);
      throw error;
    }
  }

  /**
   * Delete file
   */
  async deleteFile(filePath) {
    try {
      const fileRef = ref(storage, filePath);
      await deleteObject(fileRef);
    } catch (error) {
      console.error('Error deleting file:', error);
      throw error;
    }
  }

  /**
   * Get user profile photos
   */
  async getUserProfilePhotos(uid) {
    try {
      const userRef = ref(storage, `users/${uid}/profile`);
      const result = await listAll(userRef);

      const urls = [];
      for (const item of result.items) {
        const url = await getDownloadURL(item);
        urls.push(url);
      }

      return urls;
    } catch (error) {
      console.error('Error getting user profile photos:', error);
      throw error;
    }
  }

  /**
   * Delete user profile photos
   */
  async deleteUserProfilePhotos(uid) {
    try {
      const userRef = ref(storage, `users/${uid}/profile`);
      const result = await listAll(userRef);

      for (const item of result.items) {
        await deleteObject(item);
      }
    } catch (error) {
      console.error('Error deleting user profile photos:', error);
      throw error;
    }
  }

  /**
   * Optimize image (client-side)
   */
  async optimizeImage(file, maxWidth = 1200, maxHeight = 1200, quality = 0.8) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();

      reader.onload = (e) => {
        const img = new Image();

        img.onload = () => {
          const canvas = document.createElement('canvas');
          let width = img.width;
          let height = img.height;

          if (width > height) {
            if (width > maxWidth) {
              height = (height * maxWidth) / width;
              width = maxWidth;
            }
          } else {
            if (height > maxHeight) {
              width = (width * maxHeight) / height;
              height = maxHeight;
            }
          }

          canvas.width = width;
          canvas.height = height;

          const ctx = canvas.getContext('2d');
          ctx.drawImage(img, 0, 0, width, height);

          canvas.toBlob(
            (blob) => {
              resolve(blob);
            },
            file.type,
            quality
          );
        };

        img.onerror = () => {
          reject(new Error('Failed to load image'));
        };

        img.src = e.target.result;
      };

      reader.onerror = () => {
        reject(new Error('Failed to read file'));
      };

      reader.readAsDataURL(file);
    });
  }

  /**
   * Validate image file
   */
  validateImageFile(file, maxSizeMB = 10) {
    const validTypes = ['image/jpeg', 'image/png', 'image/webp'];
    const maxSizeBytes = maxSizeMB * 1024 * 1024;

    if (!validTypes.includes(file.type)) {
      throw new Error('Invalid file type. Please upload a JPEG, PNG, or WebP image.');
    }

    if (file.size > maxSizeBytes) {
      throw new Error(`File size exceeds ${maxSizeMB}MB limit.`);
    }

    return true;
  }

  /**
   * Upload multiple files
   */
  async uploadMultipleFiles(uid, files, folder = 'profile') {
    try {
      const uploadPromises = files.map((file) => {
        const timestamp = Date.now();
        const randomString = Math.random().toString(36).substring(7);
        const fileRef = ref(
          storage,
          `users/${uid}/${folder}/${timestamp}-${randomString}`
        );

        return uploadBytes(fileRef, file, {
          contentType: file.type,
        }).then(() => getDownloadURL(fileRef));
      });

      const urls = await Promise.all(uploadPromises);
      return urls;
    } catch (error) {
      console.error('Error uploading multiple files:', error);
      throw error;
    }
  }

  /**
   * Get download URL
   */
  async getDownloadUrl(filePath) {
    try {
      const fileRef = ref(storage, filePath);
      return await getDownloadURL(fileRef);
    } catch (error) {
      console.error('Error getting download URL:', error);
      throw error;
    }
  }
}

export default new FirebaseStorageService();
