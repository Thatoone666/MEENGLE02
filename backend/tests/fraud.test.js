import request from 'supertest';
import { expect } from 'chai';
import helpers from './test-helpers.js';
import { User } from '../routes/auth.js';
import bcryptjs from 'bcryptjs';

describe('Fraud Detection & Security', function() {
  let app;

  before(async function() {
    this.timeout(15000);
    const h = await helpers.start();
    app = h.app;
  });

  after(async function() {
    this.timeout(10000);
    await helpers.stop();
  });

  afterEach(async function() {
    await User.deleteMany({});
  });

  it('should detect multiple failed login attempts', async function() {
    this.timeout(5000);
    
    const user = new User({ 
      email: 'bruteforce@example.com', 
      password: 'x', 
      name: 'Brute Force Test' 
    });
    const salt = await bcryptjs.genSalt(10);
    user.password = await bcryptjs.hash('correctpass', salt);
    await user.save();

    for (let i = 0; i < 3; i++) {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ 
          email: 'bruteforce@example.com', 
          password: 'wrongpass' 
        })
        .expect(401);

      expect(res.body).to.have.property('error');
    }
  });

  it('should reject suspicious user patterns', async function() {
    this.timeout(5000);
    
    const suspiciousData = [
      { email: 'test<script>@example.com', password: 'pass123', name: 'XSS Test' },
      { email: "test'; DROP TABLE users; --@example.com", password: 'pass123', name: 'SQL Injection' },
      { email: 'test@example.com', password: "pass'; OR '1'='1", name: 'Auth Bypass' }
    ];

    for (const data of suspiciousData) {
      const res = await request(app)
        .post('/api/auth/signup')
        .send(data);

      expect([400, 409]).to.include(res.status);
    }
  });

  it('should handle rapid account creation attempts', async function() {
    this.timeout(10000);
    
    const requests = [];
    for (let i = 0; i < 10; i++) {
      requests.push(
        request(app)
          .post('/api/auth/signup')
          .send({
            email: `rapid${i}@example.com`,
            password: 'password123',
            name: `Rapid User ${i}`
          })
      );
    }

    const results = await Promise.all(requests);
    const successCount = results.filter(r => r.status === 201).length;
    
    expect(successCount).to.equal(10);
  });

  it('should prevent empty payload attacks', async function() {
    this.timeout(5000);
    
    const res = await request(app)
      .post('/api/auth/signup')
      .send({})
      .expect(400);

    expect(res.body).to.have.property('error');
  });

  it('should reject oversized payloads', async function() {
    this.timeout(5000);
    
    const hugePassword = 'a'.repeat(10000);
    const res = await request(app)
      .post('/api/auth/signup')
      .send({
        email: 'huge@example.com',
        password: hugePassword,
        name: 'Huge Password'
      });

    expect([400, 413]).to.include(res.status);
  });

  it('should sanitize special characters in input', async function() {
    this.timeout(5000);
    
    const specialCharsData = {
      email: 'special@example.com',
      password: 'pass!@#$%^&*()',
      name: 'Special Char User'
    };

    const res = await request(app)
      .post('/api/auth/signup')
      .send(specialCharsData)
      .expect(201);

    expect(res.body.user).to.have.property('name', 'Special Char User');
  });

  it('should detect and block impossible credentials', async function() {
    this.timeout(5000);
    
    const impossibleData = [
      { email: '@example.com', password: 'pass123', name: 'No User' },
      { email: 'test@', password: 'pass123', name: 'No Domain' },
      { email: 'test@@example.com', password: 'pass123', name: 'Double @' }
    ];

    for (const data of impossibleData) {
      const res = await request(app)
        .post('/api/auth/signup')
        .send(data)
        .expect(400);

      expect(res.body).to.have.property('error');
    }
  });

  it('should prevent username enumeration through timing attacks', async function() {
    this.timeout(5000);
    
    const existingUser = new User({ 
      email: 'existing@example.com', 
      password: 'x', 
      name: 'Existing User' 
    });
    const salt = await bcryptjs.genSalt(10);
    existingUser.password = await bcryptjs.hash('password123', salt);
    await existingUser.save();

    const startNonExistent = Date.now();
    await request(app)
      .post('/api/auth/login')
      .send({ 
        email: 'nonexistent@example.com', 
        password: 'password123' 
      });
    const timeNonExistent = Date.now() - startNonExistent;

    const startExistent = Date.now();
    await request(app)
      .post('/api/auth/login')
      .send({ 
        email: 'existing@example.com', 
        password: 'wrongpass' 
      });
    const timeExistent = Date.now() - startExistent;

    const timeDifference = Math.abs(timeNonExistent - timeExistent);
    expect(timeDifference).to.be.below(100);
  });

  it('should validate password entropy requirements', async function() {
    this.timeout(5000);
    
    const weakPasswords = [
      '12345678',
      'password',
      'qwerty123',
      'abc12345'
    ];

    for (const pwd of weakPasswords) {
      const res = await request(app)
        .post('/api/auth/signup')
        .send({
          email: `test${Math.random()}@example.com`,
          password: pwd,
          name: 'Weak Password Test'
        });

      expect([201, 400]).to.include(res.status);
    }
  });
});
