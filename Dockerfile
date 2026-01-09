FROM node:18-alpine

WORKDIR /app

# Copy backend
COPY backend/ ./backend/
RUN cd backend && npm install

# Copy frontend
COPY frontend/ ./frontend/
RUN cd frontend && npm install && npm run build

# Copy built files to server directory
RUN mkdir -p /app/public && cp -r frontend/dist/* /app/public/

# Install production server
WORKDIR /app/backend
RUN npm prune --production

EXPOSE 3001

# Start backend server
CMD ["npm", "start"]
