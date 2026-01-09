# Meengle System Architecture

## Overview
Meengle is a full-stack web and mobile application that connects people based on shared interests and geographic proximity. The system is built with a modern, scalable architecture.

## Architecture Diagram

```
???????????????????????????????????????????????????????????????
?                      User Interface Layer                    ?
???????????????????????????????????????????????????????????????
?  Web (Vite + Vue/React)  ?  Mobile (React Native/Flutter)   ?
??????????????????????????????????????????????????????????????
                  ?
        ??????????????????????
        ?                    ?
        v                    v
????????????????????  ??????????????????????
?   API Gateway    ?  ?  WebSocket Server  ?
?   (Express)      ?  ?   (Socket.io)      ?
????????????????????  ??????????????????????
        ?                    ?
        ??????????????????????
                  ?
        ??????????v?????????????????????????
        ?   Application Services Layer      ?
        ?????????????????????????????????????
        ? • Auth Service                    ?
        ? • User Service                    ?
        ? • Matching Service                ?
        ? • Chat Service                    ?
        ? • Payment Service                 ?
        ? • Notification Service            ?
        ????????????????????????????????????
                  ?
    ????????????????????????????????????????????
    ?             ?             ?              ?
    v             v             v              v
??????????  ???????????  ????????????  ??????????????
?MongoDB ?  ? Redis   ?  ?AWS S3    ?  ?External    ?
?Database?  ?Cache    ?  ?Storage   ?  ?Services    ?
??????????  ???????????  ????????????  ??????????????
```

## Technology Stack

### Frontend
- **Framework**: Vue 3 / React
- **Build Tool**: Vite
- **State Management**: Vuex / Redux
- **Real-time**: Socket.io client
- **Styling**: Tailwind CSS, SASS
- **HTTP Client**: Axios
- **Testing**: Vitest, Cypress

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB
- **Cache**: Redis
- **ORM**: Mongoose
- **Authentication**: JWT
- **File Storage**: AWS S3
- **Payment**: Stripe
- **Notifications**: Firebase Cloud Messaging
- **Logging**: Winston
- **Testing**: Jest, Supertest

### DevOps & Deployment
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Web Server**: Nginx
- **Process Manager**: PM2
- **CI/CD**: GitHub Actions
- **Cloud**: AWS (EC2, S3, CloudFront)

## Core Components

### 1. Authentication Service
- JWT-based authentication
- OAuth 2.0 integration
- Email verification
- Password reset flow
- Session management
- Token refresh mechanism

### 2. User Service
- Profile management
- Preference settings
- Avatar/image upload
- Account verification
- Location management
- Interest management

### 3. Matching Engine
- Algorithm-based matching
- Location-based matching
- Interest-based matching
- Preference filtering
- Mutual match detection
- Recommendation system

### 4. Chat & Messaging
- Real-time messaging via WebSocket
- Message history
- Typing indicators
- Read receipts
- File sharing
- Message search

### 5. Payment Service
- Stripe integration
- Subscription management
- Payment processing
- Refund handling
- Invoice generation
- Billing history

### 6. Notification System
- Push notifications
- Email notifications
- In-app notifications
- FCM integration
- Notification preferences
- Delivery tracking

### 7. Media Management
- Image upload & storage (AWS S3)
- Image optimization
- CDN integration
- Gallery management
- Video streaming support

## Database Schema

### Collections

**Users**
```javascript
{
  _id: ObjectId,
  email: String (unique),
  password: String (hashed),
  name: String,
  gender: String,
  dateOfBirth: Date,
  bio: String,
  profileImage: String,
  location: {
    type: Point,
    coordinates: [longitude, latitude]
  },
  interests: [String],
  verified: Boolean,
  subscriptionTier: String,
  createdAt: Date,
  updatedAt: Date
}
```

**Matches**
```javascript
{
  _id: ObjectId,
  userId1: ObjectId,
  userId2: ObjectId,
  status: String, // 'pending', 'accepted', 'rejected'
  likedBy: [ObjectId],
  superLikedBy: [ObjectId],
  createdAt: Date,
  updatedAt: Date
}
```

**Messages**
```javascript
{
  _id: ObjectId,
  conversationId: ObjectId,
  senderId: ObjectId,
  content: String,
  type: String,
  read: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

**Conversations**
```javascript
{
  _id: ObjectId,
  participants: [ObjectId],
  lastMessage: String,
  lastMessageTime: Date,
  unreadCounts: Map,
  createdAt: Date,
  updatedAt: Date
}
```

## API Flow

### Authentication Flow
```
User Input ? Validation ? Password Hash ? JWT Generation ? Response
```

### Matching Flow
```
User Profile ? Algorithm ? Filters ? Results ? Cache ? Response
```

### Message Flow
```
Send Message ? Store ? WebSocket Emit ? Recipient ? Notification ? Response
```

### Payment Flow
```
Checkout ? Stripe Intent ? Payment Confirmation ? Status Update ? Webhook
```

## Caching Strategy

### Redis Cache Layers
1. **User Cache**: TTL 1 hour
2. **Session Cache**: TTL 24 hours
3. **Match Cache**: TTL 1 hour
4. **Search Cache**: TTL 10 minutes
5. **Notification Cache**: TTL 1 hour

### Cache Invalidation
- On-demand invalidation
- TTL-based expiration
- Event-driven invalidation
- Partial cache clearing

## Security Architecture

### Authentication & Authorization
- JWT tokens with expiration
- Refresh token rotation
- CORS configuration
- API key validation

### Data Protection
- Password hashing (bcrypt)
- Data encryption at rest
- HTTPS/TLS encryption in transit
- PCI DSS compliance for payments

### Rate Limiting
- IP-based rate limiting
- User-based rate limiting
- Endpoint-specific limits
- DDoS protection

### Input Validation
- Schema validation
- Sanitization
- XSS prevention
- SQL injection prevention

## Scalability

### Horizontal Scaling
- Stateless API servers
- Load balancing with Nginx
- Redis for shared state
- Database replication

### Vertical Scaling
- Node.js clustering
- Memory optimization
- Database indexing
- Query optimization

### Performance Optimization
- Response caching
- Query optimization
- Image optimization
- Code splitting (frontend)
- CDN for static assets

## Deployment Architecture

### Development Environment
```
Local Machine
??? Frontend (Vite dev server)
??? Backend (Node.js)
??? MongoDB (local/Docker)
??? Redis (Docker)
```

### Staging Environment
```
Staging Server
??? Docker Containers
?   ??? API (Express)
?   ??? MongoDB
?   ??? Redis
??? Nginx (reverse proxy)
??? Monitoring & Logs
```

### Production Environment
```
AWS Infrastructure
??? EC2 Instances (auto-scaled)
?   ??? API Servers
?   ??? Worker Processes
?   ??? Monitoring Agents
??? RDS MongoDB
??? ElastiCache Redis
??? S3 (file storage)
??? CloudFront (CDN)
??? Application Load Balancer
??? CloudWatch (monitoring)
```

## Data Flow

### User Registration
```
Frontend ? API ? Validation ? DB ? Email Service ? Response
```

### Real-time Messaging
```
Sender ? WebSocket ? Server ? Cache ? DB ? WebSocket ? Recipient
         ? Notification Service ? Push/Email
```

### Payment Processing
```
Frontend ? Stripe Client ? Server ? Stripe API ? Webhook Handler ? DB
```

## Monitoring & Observability

### Metrics
- Request latency
- Error rates
- Database query performance
- Cache hit rates
- WebSocket connections
- Payment success rate

### Logs
- Application logs
- Access logs
- Error logs
- Audit logs
- Database logs

### Alerts
- High error rate
- Database unavailable
- Redis unavailable
- High memory usage
- Payment processing failures

## Disaster Recovery

### Backup Strategy
- Daily MongoDB backups
- S3 versioning for files
- Configuration backups
- Database replication

### Recovery Procedures
- Point-in-time recovery
- Failover to secondary database
- Redis replication
- Service restart procedures

## Future Enhancements

1. **Microservices Migration**: Break down into separate services
2. **Kubernetes**: Container orchestration at scale
3. **Event-Driven Architecture**: Kafka for event streaming
4. **Machine Learning**: Advanced matching algorithms
5. **GraphQL**: Alternative API for better data fetching
6. **CDN Optimization**: Better global distribution

## References

- [API Documentation](./API_DOCS.md)
- [Setup Guide](./SETUP.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
