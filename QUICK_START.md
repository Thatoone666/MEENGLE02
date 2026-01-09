# ?? Meengle Quick Start Guide

## One-Minute Setup

### 1. Clone & Install
```bash
cd C:\Users\thusowaver\Desktop\Coding Mingle
npm install
cd frontend && npm install && cd ..
cd backend && npm install && cd ..
```

### 2. Configure Environment
```bash
# Copy template
copy .env.example .env

# Edit .env with your settings:
# - MONGODB_URI
# - JWT_SECRET
# - STRIPE_SECRET_KEY
# - AWS credentials
# - Email settings
```

### 3. Start Development
```bash
npm run dev:all
# or separately:
# Terminal 1: cd frontend && npm run dev
# Terminal 2: cd backend && npm start
# Terminal 3: Start MongoDB & Redis (Docker: docker-compose up)
```

---

## Common Commands

### Build
```bash
# Build everything
build-web.bat --all

# Build frontend only
build-web.bat

# Build with tests
build-web.bat --all --test

# Clean and rebuild
build-web.bat --all --clean

# Build Docker images
build-web.bat --all --docker
```

### Development
```bash
# Frontend (http://localhost:5173)
cd frontend
npm run dev

# Backend (http://localhost:3000)
cd backend
npm start

# Both together
npm run dev:all
```

### Testing
```bash
# Frontend tests
cd frontend && npm test

# Backend tests
cd backend && npm test

# E2E tests
npm run test:e2e

# With coverage
npm run test:coverage
```

### Database
```bash
# Run migrations
cd backend && npm run migrate

# Create indexes
npm run db:index

# Test connection
npm run db:test

# Backup
mongodump --uri "mongodb://localhost:27017/meengle" --out ./backup
```

### Cache
```bash
# Test Redis
npm run redis:test

# Clear cache
redis-cli FLUSHALL

# Monitor
redis-cli monitor
```

### Deployment
```bash
# Development
./scripts/deploy.sh development

# Staging
./scripts/deploy.sh staging

# Production
./scripts/deploy.sh production
```

### Process Management (PM2)
```bash
# Start
pm2 start pm2.config.js

# Status
pm2 status

# Logs
pm2 logs

# Restart
pm2 restart all

# Stop
pm2 stop all
```

### Docker
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Rebuild
docker-compose build --no-cache
```

---

## File Structure Quick Reference

```
meengle/
??? frontend/                 # Vue/React frontend
?   ??? assets/              # CSS, JS, images
?   ??? pages/               # HTML pages
?   ??? package.json
?   ??? vite.config.js
?
??? backend/                 # Node.js API
?   ??? models/              # Database models
?   ??? routes/              # API routes
?   ??? services/            # Business logic (6 new services)
?   ??? middleware/          # Express middleware
?   ??? config/              # Configuration (3 new files)
?   ??? socket/              # WebSocket handlers
?   ??? index.js
?   ??? package.json
?
??? scripts/                 # Automation scripts
?   ??? deploy.sh            # Deployment (NEW)
?   ??? encode-secret.ps1
?
??? docs/                    # Documentation (ADD IF NEEDED)
?   ??? API_DOCS.md          # API reference (NEW)
?   ??? SETUP.md             # Setup guide (NEW)
?   ??? ARCHITECTURE.md      # Architecture (NEW)
?   ??? TROUBLESHOOTING.md   # Troubleshooting (NEW)
?
??? nginx.conf               # Nginx config
??? docker-compose.yml       # Docker config
??? Dockerfile               # Frontend container
??? Dockerfile.backend       # Backend container
??? pm2.config.js            # PM2 config (NEW)
??? .env.example             # Environment template
??? .env.production          # Production config
??? package.json             # Root package.json
??? build-web.bat            # Build script (ENHANCED)
```

---

## API Endpoints Quick Reference

### Authentication
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
```

### Users
```
GET    /api/v1/users/profile
PUT    /api/v1/users/profile
GET    /api/v1/users/:userId
POST   /api/v1/users/avatar
```

### Matches
```
GET    /api/v1/matches
POST   /api/v1/matches/:userId/like
POST   /api/v1/matches/:userId/pass
POST   /api/v1/matches/:userId/superlike
GET    /api/v1/matches/mutual
```

### Messages
```
POST   /api/v1/messages
GET    /api/v1/messages/:conversationId
GET    /api/v1/conversations
DELETE /api/v1/messages/:messageId
PUT    /api/v1/messages/:messageId
```

### Payments
```
POST   /api/v1/payments/create-intent
POST   /api/v1/payments/confirm
GET    /api/v1/subscriptions
POST   /api/v1/subscriptions/cancel
```

### Notifications
```
GET    /api/v1/notifications
PUT    /api/v1/notifications/:notificationId/read
DELETE /api/v1/notifications/:notificationId
POST   /api/v1/notifications/subscribe
```

### Search
```
GET    /api/v1/search
GET    /api/v1/search/trending
```

---

## Environment Variables Reference

```env
# Server
NODE_ENV=development
PORT=3000
HOST=localhost

# Database
MONGODB_URI=mongodb://localhost:27017/meengle
MONGODB_PASSWORD=password

# Cache
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Authentication
JWT_SECRET=your_secret_key_here
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=refresh_secret_key
JWT_REFRESH_EXPIRES_IN=30d

# Email
EMAIL_SERVICE=gmail
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password

# AWS
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=us-east-1
AWS_S3_BUCKET=your_bucket

# Stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Google Maps
GOOGLE_MAPS_API_KEY=your_api_key

# Firebase
FIREBASE_API_KEY=your_key
FIREBASE_AUTH_DOMAIN=your_domain
FIREBASE_PROJECT_ID=your_project

# Logging
LOG_LEVEL=info
LOG_FORMAT=json

# CORS
CORS_ORIGIN=http://localhost:5173,https://yourdomain.com
```

---

## Troubleshooting Quick Links

| Issue | Solution |
|-------|----------|
| MongoDB won't connect | [See TROUBLESHOOTING.md](./TROUBLESHOOTING.md#mongodb-connection-failed) |
| Redis won't connect | [See TROUBLESHOOTING.md](./TROUBLESHOOTING.md#redis-connection-failed) |
| Port already in use | [See TROUBLESHOOTING.md](./TROUBLESHOOTING.md#port-already-in-use) |
| CORS errors | [See TROUBLESHOOTING.md](./TROUBLESHOOTING.md#cors-error) |
| Build fails | [See TROUBLESHOOTING.md](./TROUBLESHOOTING.md#build-fails) |
| Tests fail | Run `npm run test:debug` for verbose output |
| Payment issues | [See TROUBLESHOOTING.md](./TROUBLESHOOTING.md#payment-processing-failed) |

---

## Health Check

```bash
# Check API
curl http://localhost:3000/api/v1/health

# Check database
npm run db:test

# Check Redis
npm run redis:test

# Full health report
node backend/health-check.js
```

---

## Useful Resources

- ?? [Full Setup Guide](./SETUP.md)
- ?? [API Documentation](./API_DOCS.md)
- ??? [Architecture Overview](./ARCHITECTURE.md)
- ?? [Troubleshooting Guide](./TROUBLESHOOTING.md)
- ?? [Build System](./BUILD_COMPLETE.md)

---

## Need Help?

1. **Check docs**: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) has 50+ solutions
2. **Check logs**: `pm2 logs` or `docker-compose logs -f`
3. **Run health check**: `node backend/health-check.js`
4. **Check console**: Browser DevTools (F12) for frontend issues

---

## Performance Tips

```bash
# Enable caching
REDIS_ENABLED=true npm start

# Increase memory (if needed)
NODE_OPTIONS=--max-old-space-size=2048 npm start

# Production build optimization
npm run build:analyze

# Database optimization
npm run db:optimize
```

---

## Production Checklist

- [ ] Update `.env.production` with real credentials
- [ ] Enable HTTPS/SSL
- [ ] Configure firewall rules
- [ ] Set up backups (MongoDB + S3)
- [ ] Configure CDN for static assets
- [ ] Set up monitoring/logging
- [ ] Run security audit: `npm audit`
- [ ] Load testing: `npm run test:load`
- [ ] Deploy: `./scripts/deploy.sh production`

---

**Last Updated**: 2026-01-08  
**Version**: 2.0.0  
**Status**: ? Complete
