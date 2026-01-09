const aws = require('aws-sdk');
const path = require('path');
const fs = require('fs').promises;
const logger = require('../config/logger');

const s3 = new aws.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1',
});

class StorageService {
  /**
   * Upload file to S3
   */
  async uploadFile(fileBuffer, filename, folder = 'uploads') {
    try {
      const key = `${folder}/${Date.now()}-${filename}`;
      
      const params = {
        Bucket: process.env.AWS_S3_BUCKET,
        Key: key,
        Body: fileBuffer,
        ContentType: this.getContentType(filename),
        ACL: 'public-read',
      };

      const result = await s3.upload(params).promise();
      logger.info('File uploaded to S3', { 
        key, 
        url: result.Location 
      });
      return result.Location;
    } catch (error) {
      logger.error('Failed to upload file', { 
        filename, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Upload image with optimization
   */
  async uploadImage(fileBuffer, filename, folder = 'images') {
    try {
      const key = `${folder}/${Date.now()}-${filename}`;
      
      const params = {
        Bucket: process.env.AWS_S3_BUCKET,
        Key: key,
        Body: fileBuffer,
        ContentType: 'image/jpeg',
        Metadata: {
          'Cache-Control': 'max-age=31536000',
        },
      };

      const result = await s3.upload(params).promise();
      logger.info('Image uploaded to S3', { 
        key, 
        url: result.Location 
      });
      return result.Location;
    } catch (error) {
      logger.error('Failed to upload image', { 
        filename, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Delete file from S3
   */
  async deleteFile(url) {
    try {
      const key = new URL(url).pathname.substring(
        new URL(url).pathname.indexOf('/') + 1
      );
      
      const params = {
        Bucket: process.env.AWS_S3_BUCKET,
        Key: key,
      };

      await s3.deleteObject(params).promise();
      logger.info('File deleted from S3', { url });
      return true;
    } catch (error) {
      logger.error('Failed to delete file', { 
        url, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Get signed URL for private file
   */
  async getSignedUrl(filename, expiresIn = 3600) {
    try {
      const params = {
        Bucket: process.env.AWS_S3_BUCKET,
        Key: filename,
        Expires: expiresIn,
      };

      const url = await s3.getSignedUrlPromise('getObject', params);
      return url;
    } catch (error) {
      logger.error('Failed to generate signed URL', { 
        filename, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Save file locally
   */
  async saveLocal(fileBuffer, filename, folder = 'uploads') {
    try {
      const uploadDir = path.join(__dirname, '../uploads', folder);
      
      // Create directory if it doesn't exist
      await fs.mkdir(uploadDir, { recursive: true });
      
      const filePath = path.join(uploadDir, filename);
      await fs.writeFile(filePath, fileBuffer);
      
      logger.info('File saved locally', { 
        path: filePath 
      });
      return filePath;
    } catch (error) {
      logger.error('Failed to save file locally', { 
        filename, 
        error: error.message 
      });
      throw error;
    }
  }

  /**
   * Get content type from filename
   */
  getContentType(filename) {
    const ext = path.extname(filename).toLowerCase();
    const mimeTypes = {
      '.pdf': 'application/pdf',
      '.doc': 'application/msword',
      '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.zip': 'application/zip',
      '.txt': 'text/plain',
    };
    return mimeTypes[ext] || 'application/octet-stream';
  }

  /**
   * Validate file size
   */
  isValidFileSize(fileSize, maxSizeMB = 10) {
    const maxBytes = maxSizeMB * 1024 * 1024;
    return fileSize <= maxBytes;
  }

  /**
   * Validate file type
   */
  isValidFileType(filename, allowedTypes = []) {
    if (allowedTypes.length === 0) return true;
    
    const ext = path.extname(filename).toLowerCase();
    return allowedTypes.some(type => ext.endsWith(type));
  }
}

module.exports = new StorageService();
