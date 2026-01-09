# Environment Variables Guide

## Overview
Meengle uses environment variables to configure different aspects of the application. Environment variables should never be committed to version control.

## File Structure

### `.env.example`
Template file with all required and optional variables. Use as reference.

### `.env.development`
Development environment configuration. Safe to include in version control without secrets.

### `.env.staging`
Staging environment configuration for pre-production testing.

### `.env.production`
Production environment configuration. **NEVER commit with real secrets**.

### `.env` (local)
Local development overrides. **NEVER commit**.

---

## Core Configuration

### Server Settings
```env
# Node environment
NODE_ENV=development|staging|production

# Server port
PORT=3000

# Server hostname
HOST=localhost

# API prefix
API_PREFIX=/api/v1

# API timeout (milliseconds)
API_TIMEOUT=30000
```

### Logging
```env
# Log level: trace, debug, info, warn, error
LOG_LEVEL=info

# Log format: json, text
LOG_FORMAT=json

# Enable file logging
LOG_TO_FILE=true

# Log directory
LOG_DIR=./logs
```

### CORS
```env
# Allowed origins (comma-separated)
CORS_ORIGIN=http://localhost:5173,https://yourdomain.com

# Allow credentials
CORS_CREDENTIALS=true

# Allowed methods
CORS_METHODS=GET,POST,PUT,DELETE,PATCH

# Allowed headers
CORS_HEADERS=Content-Type,Authorization
```

---

## Database Configuration

### MongoDB
```env
# Connection string
MONGODB_URI=mongodb://user:password@localhost:27017/meengle

# Or separate components
MONGODB_HOST=localhost
MONGODB_PORT=27017
MONGODB_USER=user
MONGODB_PASSWORD=password
MONGODB_DATABASE=meengle

# Connection options
MONGODB_POOL_SIZE=10
MONGODB_RETRY_WRITES=true
```

### Database Features
```env
# Enable database profiling
MONGODB_PROFILING_LEVEL=0

# Profiling slow query threshold (ms)
MONGODB_SLOW_QUERY_THRESHOLD=100

# Enable database encryption
MONGODB_ENCRYPTION=false
```

---

## Cache Configuration

### Redis
```env
# Redis host
REDIS_HOST=localhost

# Redis port
REDIS_PORT=6379

# Redis password
REDIS_PASSWORD=

# Redis database number
REDIS_DB=0

# Redis key prefix
REDIS_KEY_PREFIX=meengle:

# Enable Redis
REDIS_ENABLED=true

# Connection timeout (ms)
REDIS_TIMEOUT=5000

# Retry delay (ms)
REDIS_RETRY_DELAY=100

# Max retries
REDIS_MAX_RETRIES=10
```

### Cache Settings
```env
# Cache warming
CACHE_WARMING=true

# Cache warm interval (ms)
CACHE_WARM_INTERVAL=3600000

# Cache invalidation on update
CACHE_INVALIDATE_ON_UPDATE=true
```

---

## Authentication

### JWT
```env
# JWT secret key
JWT_SECRET=your_super_secret_key_here_min_32_chars

# JWT expiration
JWT_EXPIRES_IN=7d

# JWT refresh secret
JWT_REFRESH_SECRET=your_refresh_secret_key

# JWT refresh expiration
JWT_REFRESH_EXPIRES_IN=30d

# JWT algorithm
JWT_ALGORITHM=HS256
```

### OAuth 2.0 (Optional)
```env
# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# GitHub OAuth
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
```

---

## Email Configuration

### SMTP
```env
# Email service provider
EMAIL_SERVICE=gmail|sendgrid|ses|mailgun

# Email credentials
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password

# Email from address
EMAIL_FROM=noreply@meengle.com

# Email from name
EMAIL_FROM_NAME=Meengle
```

### SendGrid
```env
EMAIL_PROVIDER=sendgrid
SENDGRID_API_KEY=sg_xxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@meengle.com
```

### AWS SES
```env
EMAIL_PROVIDER=aws-ses
AWS_SES_REGION=us-east-1
AWS_SES_ROLE_ARN=arn:aws:iam::...
```

---

## Cloud Storage

### AWS
```env
# AWS credentials
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# AWS region
AWS_REGION=us-east-1

# S3 bucket
AWS_S3_BUCKET=meengle-uploads

# S3 folder
AWS_S3_FOLDER=uploads

# S3 public ACL
AWS_S3_PUBLIC_ACL=true

# CloudFront distribution
AWS_CLOUDFRONT_DISTRIBUTION=d111111abcdef8.cloudfront.net

# Enable S3 versioning
AWS_S3_VERSIONING=true
```

### Backup
```env
# Backup enabled
BACKUP_ENABLED=true

# Backup interval (hours)
BACKUP_INTERVAL=24

# Backup retention (days)
BACKUP_RETENTION=30

# Backup location
BACKUP_PATH=/backups
```

---

## Payment Processing

### Stripe
```env
# Stripe API keys
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxx

# Stripe webhook secret
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxx

# Stripe API version
STRIPE_API_VERSION=2023-10-16

# Price IDs
STRIPE_PREMIUM_PRICE_ID=price_xxxx
STRIPE_VIP_PRICE_ID=price_yyyy
```

### Payment Settings
```env
# Enable payments
ENABLE_PAYMENTS=true

# Currency
PAYMENT_CURRENCY=usd

# Supported currencies
PAYMENT_CURRENCIES=usd,eur,gbp,cad,aud

# Enable VAT
ENABLE_VAT=false

# VAT rate (if enabled)
VAT_RATE=0.19

# Refund window (days)
REFUND_WINDOW=30
```

---

## Notifications

### Firebase Cloud Messaging
```env
# Firebase config
FIREBASE_API_KEY=AIzaSyD_...
FIREBASE_AUTH_DOMAIN=meengle.firebaseapp.com
FIREBASE_PROJECT_ID=meengle-project
FIREBASE_STORAGE_BUCKET=meengle.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789

# Firebase service account (JSON)
FIREBASE_SERVICE_ACCOUNT={"type":"service_account",...}

# Enable push notifications
ENABLE_NOTIFICATIONS=true

# Notification timeout (ms)
NOTIFICATION_TIMEOUT=5000
```

---

## Maps & Geolocation

### Google Maps
```env
# Google Maps API key
GOOGLE_MAPS_API_KEY=AIzaSyD_xxxxxxxxxxxx

# Maps features
ENABLE_GEOLOCATION=true

# Geolocation precision (meters)
GEOLOCATION_PRECISION=100

# Default map center (lat,lng)
DEFAULT_MAP_CENTER=40.7128,-74.0060

# Default zoom level
DEFAULT_MAP_ZOOM=12
```

---

## Analytics & Monitoring

### Application Insights
```env
# Enable analytics
ENABLE_ANALYTICS=true

# Analytics service
ANALYTICS_SERVICE=posthog|mixpanel|amplitude

# Analytics key
ANALYTICS_API_KEY=phc_xxxxxxxxxxxx
```

### Error Tracking
```env
# Enable error tracking
ENABLE_ERROR_TRACKING=true

# Sentry DSN
SENTRY_DSN=https://xxxx@sentry.io/yyyy

# Error tracking environment
ERROR_TRACKING_ENV=development|staging|production
```

### Monitoring
```env
# Enable monitoring
ENABLE_MONITORING=true

# Monitoring service
MONITORING_SERVICE=datadog|newrelic|splunk

# Monitoring API key
MONITORING_API_KEY=xxxxxxxx
```

---

## Feature Flags

```env
# Authentication features
ENABLE_OAUTH=true
ENABLE_EMAIL_VERIFICATION=true
ENABLE_2FA=false

# Matching features
ENABLE_MATCHING=true
ENABLE_ADVANCED_FILTERS=true
ENABLE_AI_MATCHING=false

# Chat features
ENABLE_CHAT=true
ENABLE_VIDEO_CALLS=true
ENABLE_FILE_SHARING=true

# Payment features
ENABLE_PAYMENTS=true
ENABLE_SUBSCRIPTIONS=true
ENABLE_IN_APP_PURCHASES=false

# Content moderation
ENABLE_CONTENT_MODERATION=true
ENABLE_AUTOMATED_MODERATION=false
ENABLE_MANUAL_REVIEW=true
```

---

## Security Settings

### Rate Limiting
```env
# Enable rate limiting
ENABLE_RATE_LIMITING=true

# Rate limit window (minutes)
RATE_LIMIT_WINDOW=15

# Rate limit requests
RATE_LIMIT_MAX_REQUESTS=100

# Rate limit storage
RATE_LIMIT_STORE=memory|redis

# IP whitelist (comma-separated)
RATE_LIMIT_WHITELIST=127.0.0.1,::1
```

### Security Headers
```env
# Enable security headers
ENABLE_SECURITY_HEADERS=true

# Enable HSTS
ENABLE_HSTS=true

# HSTS max age (seconds)
HSTS_MAX_AGE=31536000

# Enable CSP
ENABLE_CSP=true

# Enable CORS
ENABLE_CORS=true
```

### Account Security
```env
# Password requirements
MIN_PASSWORD_LENGTH=8
REQUIRE_UPPERCASE=true
REQUIRE_NUMBERS=true
REQUIRE_SPECIAL_CHARS=true

# Account lockout
ENABLE_ACCOUNT_LOCKOUT=true
MAX_LOGIN_ATTEMPTS=5
LOCKOUT_DURATION=15

# Session timeout (minutes)
SESSION_TIMEOUT=30

# Enable suspicious login detection
ENABLE_SUSPICIOUS_LOGIN=true
```

---

## Development Settings

### Debug
```env
# Debug mode
DEBUG=meengle:*

# Enable request logging
DEBUG_REQUESTS=true

# Enable response logging
DEBUG_RESPONSES=false

# Log SQL/Database queries
DEBUG_DATABASE=false

# Log HTTP headers
DEBUG_HEADERS=false
```

### Testing
```env
# Test mode
TEST_MODE=false

# Test database
TEST_DATABASE_URL=mongodb://localhost:27017/meengle-test

# Use in-memory database for tests
TEST_USE_MEMORY_DB=false

# Test timeout (ms)
TEST_TIMEOUT=30000
```

### Development Features
```env
# Enable mock data
ENABLE_MOCK_DATA=false

# Enable seed data on startup
SEED_DATABASE=false

# Enable database reset on startup
RESET_DATABASE_ON_STARTUP=false

# Enable API documentation (Swagger)
ENABLE_SWAGGER=true

# Enable GraphQL playground
ENABLE_GRAPHQL_PLAYGROUND=false
```

---

## Deployment Settings

### Docker
```env
# Docker image tag
DOCKER_IMAGE_TAG=latest

# Docker registry
DOCKER_REGISTRY=docker.io

# Docker network
DOCKER_NETWORK=meengle-network
```

### PM2
```env
# PM2 cluster mode
PM2_CLUSTER_MODE=false

# PM2 instances
PM2_INSTANCES=max

# PM2 watch mode
PM2_WATCH=false

# PM2 ignore paths
PM2_IGNORE_WATCH=node_modules,logs,uploads
```

### Production
```env
# Production URL
PRODUCTION_URL=https://meengle.com

# API URL
API_URL=https://api.meengle.com

# Frontend URL
FRONTEND_URL=https://meengle.com

# Admin email
ADMIN_EMAIL=admin@meengle.com

# Support email
SUPPORT_EMAIL=support@meengle.com
```

---

## Setting Up Environment Variables

### 1. Local Development
```bash
# Copy template
cp .env.example .env

# Edit with your values
nano .env
```

### 2. Staging/Production
```bash
# Use separate env files
cp .env.example .env.staging
cp .env.example .env.production

# Edit with respective values
nano .env.staging
nano .env.production
```

### 3. Load Environment Variables
```bash
# In Node.js (automatic with dotenv)
require('dotenv').config();

# In shell
source .env
export $(cat .env | xargs)
```

### 4. Docker
```bash
# Pass env file to Docker
docker run --env-file .env.production myimage

# Or in docker-compose.yml
env_file:
  - .env.production
```

---

## Security Best Practices

1. **Never commit secrets**
   - Add `.env` to `.gitignore`
   - Use `.env.example` as template

2. **Use strong secrets**
   - JWT_SECRET: Min 32 characters, random
   - API keys: Use provider-generated secrets

3. **Rotate secrets regularly**
   - Monthly for development
   - Quarterly for production

4. **Use vault for production**
   - AWS Secrets Manager
   - HashiCorp Vault
   - Azure Key Vault

5. **Validate all variables**
   - Check required vars exist
   - Validate format
   - Test credentials

6. **Environment-specific values**
   - Different keys per environment
   - Different databases per environment
   - Different URLs per environment

---

## Troubleshooting

### Missing Required Variable
```bash
# Check if variable is set
echo $VARIABLE_NAME

# Or in Node.js
console.log(process.env.VARIABLE_NAME)
```

### Incorrect Value Format
```bash
# Check env file syntax
cat .env | grep "VARIABLE="

# Remove extra quotes
# Wrong: VARIABLE="value"
# Right: VARIABLE=value
```

### Changes Not Taking Effect
```bash
# Restart application
npm start

# Or with PM2
pm2 restart all
```

---

## Reference
- [SETUP.md](./SETUP.md) - Installation guide
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues
- [.env.example](./.env.example) - Template file
