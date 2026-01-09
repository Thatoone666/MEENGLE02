### Builder stage: install deps and build frontend assets
FROM node:18-alpine AS builder
WORKDIR /src
COPY package.json package-lock.json* ./
RUN npm ci --no-audit --no-fund
COPY . .
# Build web assets (esbuild)
RUN npm run build

### Runtime stage: smaller debian-slim image
FROM node:18-slim

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# Set NODE_ENV to production
ENV NODE_ENV=production

# Copy only necessary files and install production deps
COPY package.json package-lock.json* ./
RUN npm ci --production --no-audit --no-fund

# Copy backend code and built frontend from builder
COPY --chown=appuser:appgroup backend ./backend
COPY --from=builder /src/dist ./dist

USER appuser
WORKDIR /app/backend

EXPOSE 3000

# Healthcheck implemented using node (available in runtime)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD node -e "require('http').get('http://localhost:3000/healthz', res=>process.exit(res.statusCode===200?0:1)).on('error', ()=>process.exit(1))"

CMD ["node", "server.js"]
