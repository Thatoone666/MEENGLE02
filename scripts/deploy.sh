#!/bin/bash

# Meengle Deployment Script
# This script handles the deployment of the Meengle application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-production}
DEPLOY_DIR="/opt/meengle"
BACKUP_DIR="/opt/meengle-backups"
CURRENT_TIME=$(date +%Y%m%d_%H%M%S)

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}MEENGLE DEPLOYMENT SCRIPT${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script must be run as root${NC}"
   exit 1
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo -e "${RED}[ERROR] Invalid environment: $ENVIRONMENT${NC}"
    echo "Valid options: development, staging, production"
    exit 1
fi

echo -e "${YELLOW}[*] Deploying to: $ENVIRONMENT${NC}"
echo ""

# Pre-deployment checks
echo -e "${YELLOW}[*] Running pre-deployment checks...${NC}"

# Check required tools
for tool in git npm node docker docker-compose; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}[ERROR] $tool is not installed${NC}"
        exit 1
    fi
    echo -e "${GREEN}[OK] $tool installed${NC}"
done

# Check disk space
AVAILABLE_SPACE=$(df /opt | awk 'NR==2 {print $4}')
if [ "$AVAILABLE_SPACE" -lt 1000000 ]; then
    echo -e "${RED}[ERROR] Insufficient disk space${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Sufficient disk space available${NC}"

echo ""

# Create backup
echo -e "${YELLOW}[*] Creating backup...${NC}"
mkdir -p "$BACKUP_DIR"

if [ -d "$DEPLOY_DIR" ]; then
    cp -r "$DEPLOY_DIR" "$BACKUP_DIR/meengle_$CURRENT_TIME"
    echo -e "${GREEN}[OK] Backup created at $BACKUP_DIR/meengle_$CURRENT_TIME${NC}"
else
    mkdir -p "$DEPLOY_DIR"
    echo -e "${YELLOW}[WARN] No previous deployment found${NC}"
fi

echo ""

# Clone/Pull code
echo -e "${YELLOW}[*] Fetching source code...${NC}"

if [ -d "$DEPLOY_DIR/.git" ]; then
    cd "$DEPLOY_DIR"
    git pull origin main
    echo -e "${GREEN}[OK] Code updated${NC}"
else
    git clone https://github.com/yourusername/meengle.git "$DEPLOY_DIR"
    cd "$DEPLOY_DIR"
    echo -e "${GREEN}[OK] Code cloned${NC}"
fi

echo ""

# Install dependencies
echo -e "${YELLOW}[*] Installing dependencies...${NC}"

# Frontend dependencies
echo "[*] Installing frontend dependencies..."
cd frontend
npm ci --production
npm run build
echo -e "${GREEN}[OK] Frontend built${NC}"

# Backend dependencies
echo "[*] Installing backend dependencies..."
cd ../backend
npm ci --production
echo -e "${GREEN}[OK] Backend dependencies installed${NC}"

cd ..
echo ""

# Environment setup
echo -e "${YELLOW}[*] Setting up environment...${NC}"

if [ ! -f ".env.$ENVIRONMENT" ]; then
    echo -e "${RED}[ERROR] .env.$ENVIRONMENT file not found${NC}"
    exit 1
fi

cp ".env.$ENVIRONMENT" ".env"
echo -e "${GREEN}[OK] Environment configured for $ENVIRONMENT${NC}"

echo ""

# Database migrations
if [ -d "backend/migrations" ]; then
    echo -e "${YELLOW}[*] Running database migrations...${NC}"
    cd backend
    npm run migrate
    echo -e "${GREEN}[OK] Migrations completed${NC}"
    cd ..
fi

echo ""

# Stop current services
echo -e "${YELLOW}[*] Stopping current services...${NC}"

if command -v pm2 &> /dev/null; then
    pm2 stop all 2>/dev/null || true
    pm2 delete all 2>/dev/null || true
    echo -e "${GREEN}[OK] PM2 services stopped${NC}"
fi

if command -v docker-compose &> /dev/null; then
    docker-compose down 2>/dev/null || true
    echo -e "${GREEN}[OK] Docker services stopped${NC}"
fi

echo ""

# Start services based on deployment method
echo -e "${YELLOW}[*] Starting services...${NC}"

if [ "$ENVIRONMENT" = "production" ]; then
    echo "[*] Starting with Docker Compose..."
    docker-compose -f docker-compose.yml up -d
    echo -e "${GREEN}[OK] Services started with Docker${NC}"
else
    echo "[*] Starting with PM2..."
    npm install -g pm2
    pm2 start pm2.config.js --env $ENVIRONMENT
    pm2 save
    echo -e "${GREEN}[OK] Services started with PM2${NC}"
fi

echo ""

# Health checks
echo -e "${YELLOW}[*] Running health checks...${NC}"

sleep 5

# Check API health
for i in {1..5}; do
    if curl -f http://localhost:3000/api/v1/health > /dev/null 2>&1; then
        echo -e "${GREEN}[OK] API is healthy${NC}"
        break
    elif [ $i -eq 5 ]; then
        echo -e "${RED}[ERROR] API health check failed${NC}"
        exit 1
    else
        echo "[*] Waiting for API to start... (attempt $i/5)"
        sleep 5
    fi
done

echo ""

# Post-deployment
echo -e "${YELLOW}[*] Running post-deployment tasks...${NC}"

# Clear caches
if command -v redis-cli &> /dev/null; then
    redis-cli FLUSHALL
    echo -e "${GREEN}[OK] Cache cleared${NC}"
fi

# Run cleanup
if [ -f "backend/scripts/cleanup.js" ]; then
    node backend/scripts/cleanup.js
    echo -e "${GREEN}[OK] Cleanup completed${NC}"
fi

echo ""

# Deployment summary
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}DEPLOYMENT COMPLETE${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Environment: $ENVIRONMENT"
echo "Deploy Directory: $DEPLOY_DIR"
echo "Backup: $BACKUP_DIR/meengle_$CURRENT_TIME"
echo ""
echo "Services:"
echo "  - API: http://localhost:3000"
echo "  - Documentation: See API_DOCS.md"
echo ""
echo "Useful commands:"
echo "  - View logs: pm2 logs"
echo "  - Status: pm2 status"
echo "  - Restart: pm2 restart all"
echo "  - Stop: pm2 stop all"
echo ""

# Send notification (optional)
if [ ! -z "$SLACK_WEBHOOK" ]; then
    curl -X POST "$SLACK_WEBHOOK" \
        -H 'Content-Type: application/json' \
        -d "{\"text\": \"Meengle deployment to $ENVIRONMENT completed successfully\"}" \
        2>/dev/null || true
    echo -e "${GREEN}[OK] Notification sent${NC}"
fi

echo -e "${GREEN}[OK] Deployment finished at $(date)${NC}"
