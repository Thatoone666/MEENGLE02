# Meengle Setup Guide

## Prerequisites
- Node.js >= 16.0.0
- npm >= 8.0.0
- MongoDB >= 4.4
- Redis >= 6.0
- Docker (for containerized deployment)

## Installation

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/meengle.git
cd meengle
```

### 2. Install Dependencies

**Frontend:**
```bash
cd frontend
npm install
cd ..
```

**Backend:**
```bash
cd backend
npm install
cd ..
```

### 3. Environment Configuration

Copy environment template:
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```env
# Server
NODE_ENV=development
PORT=3000
HOST=localhost

# Database
MONGODB_URI=mongodb://localhost:27017/meengle
MONGODB_PASSWORD=your_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_password

# JWT
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d

# Email
EMAIL_SERVICE=gmail
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password

# AWS
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
AWS_S3_BUCKET=your_bucket

# Stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Google Maps
GOOGLE_MAPS_API_KEY=your_api_key

# Firebase
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_domain
FIREBASE_PROJECT_ID=your_project_id
```

### 4. Database Setup

**MongoDB:**
```bash
# Start MongoDB (if using local instance)
mongod

# Or use Docker
docker run -d \
  -p 27017:27017 \
  --name mongodb \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  mongo:5.0
```

**Run migrations:**
```bash
cd backend
npm run migrate
cd ..
```

### 5. Redis Setup

```bash
# Using Docker
docker run -d \
  -p 6379:6379 \
  --name redis \
  redis:7.0
```

## Development

### Start Services Individually

**Frontend (Vite dev server):**
```bash
cd frontend
npm run dev
# Opens at http://localhost:5173
```

**Backend (Node server):**
```bash
cd backend
npm run dev
# Starts at http://localhost:3000
```

### Start All Services Together

**Using npm:**
```bash
npm run dev:all
```

**Using PM2:**
```bash
pm2 start pm2.config.js --env development
pm2 logs
```

**Using Docker Compose:**
```bash
docker-compose up -d
```

### Verify Installation
```bash
# Check API health
curl http://localhost:3000/api/v1/health

# Check database connection
npm run db:test

# Check Redis connection
npm run redis:test
```

## Build for Production

### Build Frontend
```bash
cd frontend
npm run build
# Output in frontend/dist
```

### Build Backend (no build needed for Node)
```bash
cd backend
npm ci --production
```

### Build Docker Images
```bash
docker-compose build
```

## Testing

### Run Tests
```bash
# Frontend tests
cd frontend
npm test

# Backend tests
cd backend
npm test

# E2E tests
npm run test:e2e
```

### Run with Coverage
```bash
cd backend
npm run test:coverage

cd ../frontend
npm run test:coverage
```

## Deployment

### Development Deployment
```bash
./scripts/deploy.sh development
```

### Staging Deployment
```bash
./scripts/deploy.sh staging
```

### Production Deployment
```bash
./scripts/deploy.sh production
```

### Manual Deployment

**1. Prepare Environment:**
```bash
# Install dependencies
npm install

# Build frontend
cd frontend && npm run build && cd ..

# Configure environment
cp .env.production .env
```

**2. Using PM2:**
```bash
npm install -g pm2
pm2 start pm2.config.js --env production
pm2 save
pm2 startup
```

**3. Using Docker:**
```bash
docker-compose -f docker-compose.yml up -d
```

**4. Setup Reverse Proxy (Nginx):**
```bash
sudo cp nginx.conf /etc/nginx/sites-available/meengle
sudo ln -s /etc/nginx/sites-available/meengle /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Database Backup & Restore

### Backup MongoDB
```bash
mongodump --uri "mongodb://localhost:27017/meengle" \
  --out /path/to/backup
```

### Restore MongoDB
```bash
mongorestore --uri "mongodb://localhost:27017/meengle" \
  /path/to/backup
```

## Troubleshooting

### Port Already in Use
```bash
# Kill process on port 3000
lsof -i :3000
kill -9 <PID>

# Or use different port
PORT=3001 npm run dev
```

### MongoDB Connection Failed
```bash
# Check if MongoDB is running
mongosh --eval "db.version()"

# Start MongoDB
mongod --dbpath /path/to/data
```

### Redis Connection Failed
```bash
# Check if Redis is running
redis-cli ping

# Start Redis
redis-server
```

### Out of Memory
```bash
# Increase Node memory limit
NODE_OPTIONS=--max-old-space-size=2048 npm start
```

### Module Not Found
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

## Configuration Files

- **Frontend**: `frontend/.env.local`
- **Backend**: `.env`
- **Docker**: `docker-compose.yml`
- **PM2**: `pm2.config.js`
- **Nginx**: `nginx.conf`

## Logs

- **Backend logs**: `logs/` directory
- **PM2 logs**: `pm2 logs`
- **Docker logs**: `docker logs <container_id>`

## Performance Optimization

1. **Enable Caching**: Configure Redis cache in `backend/config/cache.js`
2. **Database Indexes**: Run `npm run db:index` to create indexes
3. **Frontend Optimization**: 
   ```bash
   cd frontend && npm run build:analyze
   ```
4. **Enable Compression**: Already configured in Express middleware

## Security Checklist

- [ ] Change default passwords
- [ ] Update JWT secrets
- [ ] Configure CORS properly
- [ ] Enable HTTPS
- [ ] Setup firewall rules
- [ ] Configure rate limiting
- [ ] Enable CSRF protection
- [ ] Scan for vulnerabilities: `npm audit`

## Monitoring

### Health Check
```bash
curl http://localhost:3000/api/v1/health
```

### System Monitoring
```bash
# Using PM2
pm2 monit

# Using htop
htop
```

### Application Logs
```bash
# View recent logs
tail -f logs/combined.log

# Search logs
grep "error" logs/combined.log
```

## Next Steps

1. Review [API_DOCS.md](./API_DOCS.md) for API endpoints
2. Check [ARCHITECTURE.md](./ARCHITECTURE.md) for system design
3. See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for issues
4. Read security best practices in `docs/SECURITY.md`

## Support & Community

- Documentation: https://meengle.com/docs
- Issues: https://github.com/yourusername/meengle/issues
- Email: support@meengle.com
