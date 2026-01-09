# Meengle API Documentation

## Base URL
```
https://api.meengle.com/api/v1
```

## Authentication
All API endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Response Format
All responses follow this format:
```json
{
  "success": true,
  "data": {},
  "message": "Success message",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

---

## Authentication Endpoints

### POST /auth/register
Create a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "name": "John Doe",
  "gender": "male",
  "dateOfBirth": "1990-01-01"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "userId": "user_id",
    "token": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

### POST /auth/login
Login with email and password.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt_token",
    "refreshToken": "refresh_token",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "John Doe"
    }
  }
}
```

### POST /auth/refresh
Refresh the JWT token using a refresh token.

**Request:**
```json
{
  "refreshToken": "refresh_token"
}
```

### POST /auth/logout
Logout the current user.

### POST /auth/forgot-password
Request a password reset.

**Request:**
```json
{
  "email": "user@example.com"
}
```

### POST /auth/reset-password
Reset password with token.

**Request:**
```json
{
  "token": "reset_token",
  "newPassword": "newpassword"
}
```

---

## User Endpoints

### GET /users/profile
Get current user's profile.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "John Doe",
    "gender": "male",
    "age": 34,
    "bio": "Adventure seeker",
    "location": {
      "latitude": 40.7128,
      "longitude": -74.0060,
      "address": "New York, NY"
    },
    "profileImage": "image_url",
    "verified": true,
    "subscriptionTier": "premium"
  }
}
```

### PUT /users/profile
Update user profile.

**Request:**
```json
{
  "bio": "Updated bio",
  "interests": ["hiking", "music"],
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060
  }
}
```

### GET /users/:userId
Get a user's public profile.

### POST /users/avatar
Upload user avatar.

**Multipart Form Data:**
- `avatar`: Image file

---

## Matching Endpoints

### GET /matches
Get list of potential matches.

**Query Parameters:**
- `limit`: Number of results (default: 20)
- `skip`: Number to skip (default: 0)
- `minAge`: Minimum age filter
- `maxAge`: Maximum age filter
- `gender`: Gender filter
- `distance`: Maximum distance in km

**Response:**
```json
{
  "success": true,
  "data": {
    "matches": [
      {
        "id": "match_id",
        "name": "Jane Doe",
        "age": 28,
        "gender": "female",
        "profileImage": "image_url",
        "distance": 2.5,
        "matchScore": 85
      }
    ],
    "total": 100,
    "hasMore": true
  }
}
```

### POST /matches/:userId/like
Like a user.

### POST /matches/:userId/pass
Pass on a user.

### POST /matches/:userId/superlike
Super like a user.

### GET /matches/mutual
Get mutual matches (both liked each other).

---

## Messaging Endpoints

### POST /messages
Send a message.

**Request:**
```json
{
  "recipientId": "recipient_user_id",
  "content": "Hello!",
  "type": "text"
}
```

### GET /messages/:conversationId
Get conversation messages.

**Query Parameters:**
- `limit`: Number of messages (default: 50)
- `skip`: Number to skip (default: 0)

### GET /conversations
Get list of conversations.

**Response:**
```json
{
  "success": true,
  "data": {
    "conversations": [
      {
        "id": "conversation_id",
        "participantId": "other_user_id",
        "participantName": "Jane Doe",
        "lastMessage": "See you soon!",
        "lastMessageTime": "2024-01-01T12:00:00Z",
        "unreadCount": 3
      }
    ]
  }
}
```

### DELETE /messages/:messageId
Delete a message.

### PUT /messages/:messageId
Edit a message.

---

## Payment Endpoints

### POST /payments/create-intent
Create a payment intent.

**Request:**
```json
{
  "amount": 9.99,
  "currency": "usd",
  "planId": "premium"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "clientSecret": "stripe_client_secret",
    "paymentIntentId": "stripe_intent_id"
  }
}
```

### POST /payments/confirm
Confirm payment intent.

**Request:**
```json
{
  "paymentIntentId": "stripe_intent_id",
  "paymentMethodId": "stripe_payment_method_id"
}
```

### GET /subscriptions
Get current subscription.

**Response:**
```json
{
  "success": true,
  "data": {
    "plan": "premium",
    "status": "active",
    "renewalDate": "2024-02-01",
    "autoRenew": true
  }
}
```

### POST /subscriptions/cancel
Cancel subscription.

---

## Notification Endpoints

### GET /notifications
Get notifications.

**Query Parameters:**
- `limit`: Number of notifications (default: 20)
- `skip`: Number to skip (default: 0)
- `read`: Filter by read status

### PUT /notifications/:notificationId/read
Mark notification as read.

### DELETE /notifications/:notificationId
Delete notification.

### POST /notifications/subscribe
Subscribe to push notifications.

**Request:**
```json
{
  "deviceToken": "firebase_device_token"
}
```

---

## Search Endpoints

### GET /search
Search for users.

**Query Parameters:**
- `q`: Search query
- `type`: Search type (users, messages, etc.)
- `limit`: Number of results (default: 10)

**Response:**
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "id": "user_id",
        "name": "Jane Doe",
        "profileImage": "image_url"
      }
    ]
  }
}
```

### GET /search/trending
Get trending searches.

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Invalid input",
  "message": "Email is required",
  "code": "VALIDATION_ERROR"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "Token is invalid or expired",
  "code": "AUTH_ERROR"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "Forbidden",
  "message": "You don't have permission",
  "code": "PERMISSION_ERROR"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Not Found",
  "message": "Resource not found",
  "code": "NOT_FOUND"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "error": "Rate Limit Exceeded",
  "message": "Too many requests",
  "code": "RATE_LIMIT_ERROR"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Internal Server Error",
  "message": "An unexpected error occurred",
  "code": "SERVER_ERROR"
}
```

---

## Rate Limits
- **Default**: 100 requests per 15 minutes per IP
- **Authenticated**: 1000 requests per 15 minutes per user
- **Payment endpoints**: 10 requests per 1 minute

---

## Webhooks

### Payment Webhook
- **Event**: `payment.success`
- **URL**: `POST /webhooks/stripe`
- **Headers**: `Stripe-Signature: <signature>`

### Notification Webhook
- **Event**: `notification.send`
- **URL**: `POST /webhooks/notifications`

---

## Code Examples

### JavaScript/TypeScript
```javascript
// Login
const response = await fetch('https://api.meengle.com/api/v1/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password'
  })
});

const data = await response.json();
const token = data.data.token;

// Get profile
const profileResponse = await fetch('https://api.meengle.com/api/v1/users/profile', {
  headers: { 'Authorization': `Bearer ${token}` }
});

const profile = await profileResponse.json();
console.log(profile.data);
```

### cURL
```bash
# Login
curl -X POST https://api.meengle.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Get profile
curl -X GET https://api.meengle.com/api/v1/users/profile \
  -H "Authorization: Bearer <token>"
```

---

## Support
For API support, visit: https://meengle.com/api-support
