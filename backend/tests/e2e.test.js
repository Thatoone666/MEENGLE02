import request from 'supertest';
import { expect } from 'chai';
import helpers from './test-helpers.js';
import { User } from '../routes/auth.js';
import bcryptjs from 'bcryptjs';

describe('E2E - Complete User Journey', function() {
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

  afterEach(async function() {
    await User.deleteMany({});
  });

  it('should complete full signup and login flow', async function() {
    this.timeout(5000);
    
    const signupRes = await request(app)
      .post('/api/auth/signup')
      .send({ 
        email: 'e2e@example.com', 
        password: 'password123', 
        name: 'E2E User' 
      })
      .expect(201);

    expect(signupRes.body).to.have.property('token');
    expect(signupRes.body.user).to.have.property('email', 'e2e@example.com');
    
    authToken = signupRes.body.token;
    userId = signupRes.body.user.id;

    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({ 
        email: 'e2e@example.com', 
        password: 'password123' 
      })
      .expect(200);

    expect(loginRes.body).to.have.property('token');
  });

  it('should prevent duplicate email registration', async function() {
    this.timeout(5000);
    
    const user = new User({ 
      email: 'duplicate@example.com', 
      password: 'x', 
      name: 'Existing User' 
    });
    await user.save();

    const res = await request(app)
      .post('/api/auth/signup')
      .send({ 
        email: 'duplicate@example.com', 
        password: 'password123', 
        name: 'New User' 
      })
      .expect(409);

    expect(res.body).to.have.property('error', 'User already exists');
  });

  it('should handle email and password validation', async function() {
    this.timeout(5000);
    
    const validationTests = [
      { 
        data: { email: '', password: 'password123', name: 'Test' }, 
        status: 400 
      },
      { 
        data: { email: 'test@example.com', password: '', name: 'Test' }, 
        status: 400 
      },
      { 
        data: { email: 'test@example.com', password: 'password123', name: '' }, 
        status: 400 
      }
    ];

    for (const test of validationTests) {
      const res = await request(app)
        .post('/api/auth/signup')
        .send(test.data)
        .expect(test.status);
      
      expect(res.body).to.have.property('error');
    }
  });

  it('should authenticate user and return token', async function() {
    this.timeout(5000);
    
    const user = new User({ 
      email: 'auth@example.com', 
      password: 'x', 
      name: 'Auth User' 
    });
    const salt = await bcryptjs.genSalt(10);
    user.password = await bcryptjs.hash('password123', salt);
    await user.save();

    const res = await request(app)
      .post('/api/auth/login')
      .send({ 
        email: 'auth@example.com', 
        password: 'password123' 
      })
      .expect(200);

    expect(res.body).to.have.property('token');
    expect(res.body).to.have.property('refreshToken');
    expect(res.body.user).to.have.property('email', 'auth@example.com');
  });

  it('should reject login with invalid credentials', async function() {
    this.timeout(5000);
    
    const user = new User({ 
      email: 'invalid@example.com', 
      password: 'x', 
      name: 'Invalid User' 
    });
    const salt = await bcryptjs.genSalt(10);
    user.password = await bcryptjs.hash('correct123', salt);
    await user.save();

    const res = await request(app)
      .post('/api/auth/login')
      .send({ 
        email: 'invalid@example.com', 
        password: 'wrong123' 
      })
      .expect(401);

    expect(res.body).to.have.property('error', 'Invalid credentials');
  });

  it('should reject suspended account login', async function() {
    this.timeout(5000);
    
    const user = new User({ 
      email: 'suspended@example.com', 
      password: 'x', 
      name: 'Suspended User',
      suspended: true
    });
    const salt = await bcryptjs.genSalt(10);
    user.password = await bcryptjs.hash('password123', salt);
    await user.save();

    const res = await request(app)
      .post('/api/auth/login')
      .send({ 
        email: 'suspended@example.com', 
        password: 'password123' 
      })
      .expect(403);

    expect(res.body).to.have.property('error', 'Account suspended');
  });

  it('should handle concurrent requests', async function() {
    this.timeout(10000);
    
    const requests = [];
    for (let i = 0; i < 5; i++) {
      requests.push(
        request(app)
          .post('/api/auth/signup')
          .send({
            email: `concurrent${i}@example.com`,
            password: 'password123',
            name: `User ${i}`
          })
      );
    }

    const results = await Promise.all(requests);
    results.forEach(res => {
      expect(res.status).to.equal(201);
      expect(res.body).to.have.property('token');
    });
  });
});
