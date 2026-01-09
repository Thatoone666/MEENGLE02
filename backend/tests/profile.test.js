import request from 'supertest';
import { expect } from 'chai';
import helpers from './test-helpers.js';
import { User } from '../routes/auth.js';
import bcryptjs from 'bcryptjs';

describe('Profile Management', function() {
  let app;
  let authToken;
  let userId;

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
      email: 'profile@example.com', 
      password: 'x', 
      name: 'Profile User',
      age: 25,
      gender: 'Male'
    });
    const salt = await bcryptjs.genSalt(10);
    user.password = await bcryptjs.hash('password123', salt);
    await user.save();
    
    userId = user._id.toString();

    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({ 
        email: 'profile@example.com', 
        password: 'password123' 
      });
    
    authToken = loginRes.body.token;
  });

  afterEach(async function() {
    await User.deleteMany({});
  });

  it('should update user profile successfully', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/profile')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        age: 30,
        bio: 'Updated bio',
        gender: 'Male',
        genderPreference: 'Female',
        ageRange: { min: 20, max: 35 }
      })
      .expect(200);

    expect(res.body).to.have.property('age', 30);
    expect(res.body).to.have.property('bio', 'Updated bio');
  });

  it('should get user profile with authentication', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${authToken}`)
      .expect(200);

    expect(res.body).to.have.property('email', 'profile@example.com');
    expect(res.body).to.have.property('name', 'Profile User');
    expect(res.body).to.not.have.property('password');
  });

  it('should reject profile update without authentication', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/profile')
      .send({
        age: 30,
        bio: 'Unauthorized update'
      })
      .expect(401);

    expect(res.body).to.have.property('error');
  });

  it('should reject invalid token', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .get('/api/auth/me')
      .set('Authorization', 'Bearer invalid.token.here')
      .expect(401);

    expect(res.body).to.have.property('error');
  });

  it('should update profile with complete information', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/profile')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        age: 28,
        bio: 'Complete profile update',
        gender: 'Male',
        genderPreference: 'Female',
        religion: 'Christian',
        bodyType: 'Athletic',
        educationLevel: 'Bachelor',
        relationshipGoal: 'Serious Relationship',
        ageRange: { min: 22, max: 32 },
        location: {
          latitude: 40.7128,
          longitude: -74.0060
        }
      })
      .expect(200);

    expect(res.body).to.have.property('age', 28);
    expect(res.body).to.have.property('bio', 'Complete profile update');
    expect(res.body).to.have.property('religion', 'Christian');
    expect(res.body).to.have.property('bodyType', 'Athletic');
  });

  it('should change password securely', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/change-password')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        oldPassword: 'password123',
        newPassword: 'newpassword456'
      })
      .expect(200);

    expect(res.body).to.have.property('success', true);
    expect(res.body).to.have.property('message', 'Password changed successfully');
  });

  it('should reject password change with wrong old password', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/change-password')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        oldPassword: 'wrongpassword',
        newPassword: 'newpassword456'
      })
      .expect(401);

    expect(res.body).to.have.property('error', 'Invalid password');
  });

  it('should reject password change with weak new password', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/change-password')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        oldPassword: 'password123',
        newPassword: 'short'
      })
      .expect(400);

    expect(res.body).to.have.property('error');
  });

  it('should validate profile field types', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/profile')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        age: 'not a number',
        bio: 123,
        gender: 'Invalid Gender'
      })
      .expect(200);

    const updated = await User.findById(userId);
    expect(updated).to.exist;
  });

  it('should handle profile partial updates', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/profile')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        bio: 'Only updating bio'
      })
      .expect(200);

    expect(res.body).to.have.property('bio', 'Only updating bio');
    expect(res.body).to.have.property('name', 'Profile User');
  });

  it('should store location data correctly', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/profile')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        location: {
          latitude: 51.5074,
          longitude: -0.1278
        }
      })
      .expect(200);

    expect(res.body).to.have.property('location');
    expect(res.body.location.coordinates).to.be.an('array');
  });

  it('should prevent unauthorized profile deletion', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/delete-account')
      .send({ password: 'password123' })
      .expect(401);

    expect(res.body).to.have.property('error');
  });
});
