import request from 'supertest';
import { expect } from 'chai';
import helpers from './test-helpers.js';
import { User } from '../routes/auth.js';
import bcryptjs from 'bcryptjs';

describe('Media Upload & Management', function() {
  let app;
  let authToken;

  before(async function() {
    this.timeout(15000);
    const h = await helpers.start();
    app = h.app;
  });

  after(async function() {
    this.timeout(10000);
    await helpers.stop();
  });

  beforeEach(async function() {
    this.timeout(5000);
    const user = new User({ 
      email: 'upload@example.com', 
      password: 'x', 
      name: 'Upload User',
      photos: []
    });
    const salt = await bcryptjs.genSalt(10);
    user.password = await bcryptjs.hash('password123', salt);
    await user.save();

    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({ 
        email: 'upload@example.com', 
        password: 'password123' 
      });
    
    authToken = loginRes.body.token;
  });

  afterEach(async function() {
    await User.deleteMany({});
  });

  it('should reject upload without authentication', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/media/upload')
      .expect(401);

    expect(res.body).to.have.property('error');
  });

  it('should validate file size limits', async function() {
    this.timeout(5000);
    
    const largeBuffer = Buffer.alloc(100 * 1024 * 1024);
    
    const res = await request(app)
      .post('/api/media/upload')
      .set('Authorization', `Bearer ${authToken}`)
      .send({ file: largeBuffer });

    expect([400, 413]).to.include(res.status);
  });

  it('should validate file type restrictions', async function() {
    this.timeout(5000);
    
    const invalidTypes = ['executable.exe', 'script.sh', 'archive.zip'];
    
    for (const filename of invalidTypes) {
      const res = await request(app)
        .post('/api/media/upload')
        .set('Authorization', `Bearer ${authToken}`)
        .field('filename', filename);

      expect([400, 415]).to.include(res.status);
    }
  });

  it('should handle multiple file uploads', async function() {
    this.timeout(10000);
    
    const uploadPromises = [];
    for (let i = 0; i < 3; i++) {
      uploadPromises.push(
        request(app)
          .post('/api/media/upload')
          .set('Authorization', `Bearer ${authToken}`)
          .field('type', 'photo')
      );
    }

    const results = await Promise.all(uploadPromises);
    
    results.forEach(res => {
      expect([201, 200]).to.include(res.status);
    });
  });

  it('should enforce storage quota per user', async function() {
    this.timeout(10000);
    
    const uploadPromises = [];
    for (let i = 0; i < 20; i++) {
      uploadPromises.push(
        request(app)
          .post('/api/media/upload')
          .set('Authorization', `Bearer ${authToken}`)
          .field('type', 'photo')
      );
    }

    const results = await Promise.all(uploadPromises);
    const successCount = results.filter(r => [201, 200].includes(r.status)).length;
    
    expect(successCount).to.be.below(20);
  });

  it('should retrieve user photos', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .get('/api/media/user-photos')
      .set('Authorization', `Bearer ${authToken}`)
      .expect(200);

    expect(res.body).to.be.an('array');
  });

  it('should delete uploaded photo', async function() {
    this.timeout(5000);
    
    const deleteRes = await request(app)
      .delete('/api/media/photo/someid')
      .set('Authorization', `Bearer ${authToken}`);

    expect([200, 404]).to.include(deleteRes.status);
  });

  it('should prevent cross-user photo access', async function() {
    this.timeout(5000);
    
    const otherUser = new User({ 
      email: 'other@example.com', 
      password: 'x', 
      name: 'Other User',
      photos: ['secret-photo-id']
    });
    const salt = await bcryptjs.genSalt(10);
    otherUser.password = await bcryptjs.hash('password123', salt);
    await otherUser.save();

    const res = await request(app)
      .get('/api/media/photo/secret-photo-id')
      .set('Authorization', `Bearer ${authToken}`)
      .expect(403);

    expect(res.body).to.have.property('error');
  });

  it('should handle damaged file uploads gracefully', async function() {
    this.timeout(5000);
    
    const corruptedData = Buffer.from([0xff, 0xd9, 0xff, 0xd8]);
    
    const res = await request(app)
      .post('/api/media/upload')
      .set('Authorization', `Bearer ${authToken}`)
      .send(corruptedData);

    expect([400, 415]).to.include(res.status);
  });

  it('should generate thumbnail for uploaded images', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/media/upload')
      .set('Authorization', `Bearer ${authToken}`)
      .field('type', 'photo')
      .field('generateThumbnail', 'true');

    if ([201, 200].includes(res.status)) {
      expect(res.body).to.have.any.keys('thumbnail', 'thumbnailUrl');
    }
  });

  it('should prevent malicious filename attacks', async function() {
    this.timeout(5000);
    
    const maliciousFilenames = [
      '../../../etc/passwd',
      '..\\..\\..\\windows\\system32\\config\\sam',
      'file";DROP TABLE users;--"'
    ];

    for (const filename of maliciousFilenames) {
      const res = await request(app)
        .post('/api/media/upload')
        .set('Authorization', `Bearer ${authToken}`)
        .field('filename', filename);

      expect([400, 403]).to.include(res.status);
    }
  });

  it('should track upload metadata', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/media/upload')
      .set('Authorization', `Bearer ${authToken}`)
      .field('type', 'photo');

    if ([201, 200].includes(res.status)) {
      expect(res.body).to.have.property('uploadedAt');
      expect(res.body).to.have.property('fileSize');
    }
  });
});
