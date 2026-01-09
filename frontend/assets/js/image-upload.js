// MEENGLE - Image Upload Manager
// Handles image selection, compression, and upload

class ImageUploadManager {
  constructor(maxSize = 5 * 1024 * 1024, maxFiles = 10) {
    this.maxSize = maxSize; // 5MB default
    this.maxFiles = maxFiles; // 10 files default
    this.uploadedFiles = [];
    this.allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
  }

  // Validate file
  validateFile(file) {
    // Check file type
    if (!this.allowedTypes.includes(file.type)) {
      return {
        valid: false,
        error: `File type not allowed. Allowed types: ${this.allowedTypes.join(', ')}`
      };
    }

    // Check file size
    if (file.size > this.maxSize) {
      return {
        valid: false,
        error: `File size exceeds ${this.maxSize / 1024 / 1024}MB limit`
      };
    }

    return { valid: true };
  }

  // Compress image
  async compressImage(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = (event) => {
        const img = new Image();
        img.src = event.target.result;
        img.onload = () => {
          const canvas = document.createElement('canvas');
          const ctx = canvas.getContext('2d');

          // Calculate new dimensions (max 1200px)
          let width = img.width;
          let height = img.height;
          const maxDim = 1200;

          if (width > height) {
            if (width > maxDim) {
              height = (height * maxDim) / width;
              width = maxDim;
            }
          } else {
            if (height > maxDim) {
              width = (width * maxDim) / height;
              height = maxDim;
            }
          }

          canvas.width = width;
          canvas.height = height;
          ctx.drawImage(img, 0, 0, width, height);

          canvas.toBlob(
            (blob) => {
              resolve(blob);
            },
            'image/jpeg',
            0.8 // 80% quality
          );
        };
        img.onerror = () => reject(new Error('Failed to load image'));
      };
      reader.onerror = () => reject(new Error('Failed to read file'));
    });
  }

  // Handle file selection
  async handleFileSelect(files) {
    const results = [];

    for (const file of files) {
      // Validate
      const validation = this.validateFile(file);
      if (!validation.valid) {
        results.push({
          file: file.name,
          success: false,
          error: validation.error
        });
        continue;
      }

      try {
        // Compress
        const compressedBlob = await this.compressImage(file);
        
        // Create data URL
        const reader = new FileReader();
        reader.readAsDataURL(compressedBlob);
        reader.onload = (event) => {
          results.push({
            file: file.name,
            success: true,
            dataUrl: event.target.result,
            size: compressedBlob.size
          });
        };
      } catch (error) {
        results.push({
          file: file.name,
          success: false,
          error: error.message
        });
      }
    }

    return results;
  }

  // Upload file to server
  async uploadFile(dataUrl, filename, apiClient) {
    try {
      const response = await apiClient.uploadMedia(
        filename,
        dataUrl,
        'image',
        dataUrl.length
      );

      this.uploadedFiles.push({
        filename,
        url: response.url,
        id: response.id,
        timestamp: new Date()
      });

      return { success: true, data: response };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Batch upload
  async uploadMultiple(files, apiClient) {
    const uploads = [];
    for (const file of files) {
      uploads.push(this.uploadFile(file.dataUrl, file.filename, apiClient));
    }
    return Promise.all(uploads);
  }

  // Get uploaded files
  getUploadedFiles() {
    return this.uploadedFiles;
  }

  // Clear uploads
  clearUploads() {
    this.uploadedFiles = [];
  }

  // Preview image
  previewImage(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = (event) => {
        resolve(event.target.result);
      };
      reader.onerror = () => {
        reject(new Error('Failed to read file'));
      };
    });
  }

  // Format file size
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  }
}

// Create global instance
window.imageUploadManager = new ImageUploadManager();

// Export for use in modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ImageUploadManager;
}
