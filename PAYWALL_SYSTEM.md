# ?? Paywall System Guide

## Overview

Complete paywall implementation for Meengle with feature access control based on subscription tier.

---

## ?? Paywall Features

### 1. **Feature Access Control**
- Tier-based feature availability
- Daily usage limits
- Remaining usage tracking
- Feature requirement checking

### 2. **Paywall Components**
- Modal dialogs for feature locks
- Protected buttons with automatic paywalls
- Feature-gated sections with overlays
- Usage limit notifications

### 3. **Subscription Tiers**

| Feature | Free | Spark | Spark+ | Flame | Wildfire |
|---------|------|-------|--------|-------|----------|
| Matches/Day | 10 | 50 | ? | ? | ? |
| Messages/Day | 20 | 100 | ? | ? | ? |
| Daily Swipes | 20 | 50 | ? | ? | ? |
| Advanced Filters | ? | ? | ? | ? | ? |
| Video Calls | ? | ? | ? | ? | ? |
| Rewind Feature | ? | ? | ? | ? | ? |
| Exclusive Matches | ? | ? | ? | ? | ? |
| Priority Support | ? | ? | ? | ? | ? |
| VIP Events | ? | ? | ? | ? | ? |
| Ad-Free | ? | ? | ? | ? | ? |

---

## ?? Components Created

### 1. **PaywallService** (`paywallService.js`)
```javascript
// Check if feature is available
paywallService.canAccessFeature('spark', 'videoCalls') // false
paywallService.canAccessFeature('flame', 'videoCalls') // true

// Get feature limit
paywallService.getFeatureLimit('spark', 'matches') // 50
paywallService.getFeatureLimit('sparkplus', 'matches') // Infinity

// Record usage
await paywallService.recordUsage(userId, 'matches', 1)

// Get remaining usage
const remaining = await paywallService.getRemainingUsage(userId, 'matches')
```

### 2. **PaywallModal** (`PaywallModal.jsx`)
Modal displayed when user tries to access locked feature:
- Feature requirement display
- Pricing information
- Benefits list
- Upgrade button

### 3. **ProtectedButton** (`ProtectedButton.jsx`)
Button that automatically shows paywall:
```javascript
<ProtectedButton feature="videoCalls" onClick={handleCall}>
  Start Video Call
</ProtectedButton>
```

### 4. **FeatureGated** (`FeatureGated.jsx`)
Section wrapper that blurs content for locked features:
```javascript
<FeatureGated feature="exclusiveMatches">
  <ExclusiveMatchesList />
</FeatureGated>
```

---

## ?? Integration Examples

### Protect a Button
```javascript
import ProtectedButton from '../components/ProtectedButton';

function ChatComponent() {
  return (
    <ProtectedButton 
      feature="messages"
      onClick={() => sendMessage()}
      variant="primary"
    >
      Send Message
    </ProtectedButton>
  );
}
```

### Protect a Section
```javascript
import FeatureGated from '../components/FeatureGated';

function ExclusiveMatches() {
  return (
    <FeatureGated feature="exclusiveMatches" blurRestricted={true}>
      <div>Premium Matches Only</div>
    </FeatureGated>
  );
}
```

### Check Access Programmatically
```javascript
import paywallService from '../services/paywallService';

async function handleFeature() {
  const tier = await paywallService.getUserTier(userId);
  
  if (paywallService.canAccessFeature(tier, 'videoCalls')) {
    // Start video call
  } else {
    // Show paywall
  }
}
```

### Get Remaining Usage
```javascript
const remaining = await paywallService.getRemainingUsage(userId, 'matches');

if (remaining === 0) {
  // Show "Upgrade to continue" paywall
} else if (remaining < 5) {
  // Show "Only X matches left today" warning
}
```

---

## ?? Paywall Modal Features

### Automatic Pricing Display
```
[Feature Icon]
Premium Feature

Message about feature access

Required Tier: Spark+ or higher

Monthly: R16.99 | PayFlex BNPL: R5.83/mo
(12 months interest-free)

What you'll get:
? Unlimited matches
? Unlimited messages
? Advanced filters
? Priority support

[Upgrade Now] [Maybe Later]

? Secure payment | ? Cancel anytime | ? 30-day refund
```

### Custom Messages Per Feature
```javascript
const messages = {
  videoCalls: 'Video calling available with Flame tier and above',
  exclusiveMatches: 'Exclusive matches available with Flame tier and above',
  rewindFeature: 'Rewind your last action with Spark+ or higher',
  prioritySupport: 'Priority support available with Spark+ or higher'
}
```

---

## ?? Backend Integration

### API Endpoints Required

```javascript
// Get user tier
GET /api/v1/users/:userId/tier
Response: { tier: 'spark' }

// Get feature usage
GET /api/v1/users/:userId/usage/:feature
Response: { usage: 15, limit: 50, remaining: 35 }

// Record usage
POST /api/v1/users/:userId/usage/:feature
Body: { amount: 1 }
Response: { success: true }

// Reset daily usage (scheduled job)
POST /api/v1/users/:userId/usage/reset
```

### Backend Implementation
```javascript
// In backend route handler
router.get('/users/:userId/tier', authMiddleware, async (req, res) => {
  const user = await User.findById(req.params.userId);
  res.json({ tier: user.subscriptionTier });
});

router.post('/users/:userId/usage/:feature', authMiddleware, async (req, res) => {
  const { amount } = req.body;
  
  // Record usage
  await Usage.findOneAndUpdate(
    { userId, feature, date: today },
    { $inc: { count: amount } },
    { upsert: true }
  );
  
  res.json({ success: true });
});
```

---

## ?? Usage Patterns

### Pattern 1: Daily Swipe Limit
```javascript
function SwipeCard() {
  const [remaining, setRemaining] = useState(0);

  useEffect(() => {
    getRemainingSwipes();
  }, []);

  const handleSwipe = async (direction) => {
    if (remaining <= 0) {
      showPaywall('dailySwipes');
      return;
    }

    await swipeUser(direction);
    await recordUsage('dailySwipes');
    setRemaining(remaining - 1);
  };

  return (
    <div>
      {remaining > 0 && <p>Swipes remaining: {remaining}</p>}
      {remaining <= 0 && <p>Daily limit reached</p>}
    </div>
  );
}
```

### Pattern 2: Feature Availability Check
```javascript
function VideoCallButton() {
  return (
    <ProtectedButton feature="videoCalls">
      ?? Start Video Call
    </ProtectedButton>
  );
}
```

### Pattern 3: Content Gating
```javascript
function PremiumContent() {
  return (
    <FeatureGated feature="exclusiveMatches">
      <div>Exclusive Matches (Premium Only)</div>
    </FeatureGated>
  );
}
```

---

## ?? Paywall Triggers

### Automatic Triggers
1. **Click Protected Button** ? Shows paywall modal
2. **Access Gated Section** ? Blurs content + overlay
3. **Reach Daily Limit** ? Shows "Limit reached" paywall
4. **Try Premium Feature** ? Shows feature requirement

### Manual Triggers
```javascript
// Manually show paywall
const [showPaywall, setShowPaywall] = useState(false);

<PaywallModal
  isOpen={showPaywall}
  feature="videoCalls"
  currentTier="free"
  requiredTier="flame"
  message="Video calls require Flame tier"
  onClose={() => setShowPaywall(false)}
  onUpgrade={() => window.location.href = '/payment'}
/>
```

---

## ?? Conversion Optimization

### Best Practices
1. **Early Introduction** - Show paywall at first premium action
2. **Value Emphasis** - Highlight what they'll get with upgrade
3. **Easy Upgrade** - One-click to payment page
4. **BNPL Option** - Show PayFlex for affordability
5. **Trust Signals** - "Secure payment", "Cancel anytime", "30-day refund"

### A/B Testing Ideas
- Different paywall messages
- Modal vs full-page paywall
- Pricing display format
- Feature emphasis

---

## ?? Analytics Events

```javascript
// Track paywall views
analytics.track('paywall_viewed', {
  feature: 'videoCalls',
  tier: 'free',
  requiredTier: 'flame'
});

// Track upgrade clicks
analytics.track('paywall_upgrade_clicked', {
  feature: 'videoCalls'
});

// Track successful upgrades
analytics.track('upgrade_completed', {
  from_tier: 'free',
  to_tier: 'flame'
});
```

---

## ?? Security Considerations

### Frontend Validation
- Display paywalls for locked features
- Prevent interaction with locked content
- Track usage locally for UX

### Backend Validation (Critical)
- **Always validate** on backend
- Don't trust tier from frontend
- Check permissions before executing action
- Log denied access attempts

```javascript
// IMPORTANT: Backend validation
app.post('/api/v1/messages', authMiddleware, async (req, res) => {
  const user = await User.findById(req.user.id);
  
  // Check permission on BACKEND
  if (!canAccessFeature(user.tier, 'messages')) {
    return res.status(403).json({ error: 'Feature not available' });
  }
  
  // Send message
  const message = await Message.create({ ...req.body, userId: user.id });
  res.json(message);
});
```

---

## ?? Customization

### Change Feature Limits
```javascript
// In paywallService.js
this.tierFeatures = {
  free: {
    matches: 10,
    messages: 20,
    // ... customize
  }
}
```

### Change Paywall Messages
```javascript
// In paywallService.js
this.featureDescriptions = {
  matches: 'Your custom message',
  messages: 'Your custom message',
  // ... customize
}
```

### Change Colors
```css
/* In PaywallModal.css */
.paywall-upgrade-btn {
  background: linear-gradient(135deg, #your-color, #your-color);
}
```

---

## ?? Component Files

```
frontend/
??? src/
?   ??? services/
?   ?   ??? paywallService.js
?   ??? components/
?       ??? PaywallModal.jsx
?       ??? PaywallModal.css
?       ??? ProtectedButton.jsx
?       ??? ProtectedButton.css
?       ??? FeatureGated.jsx
?       ??? FeatureGated.css
```

---

## ? Checklist

- [ ] Import paywall service in components
- [ ] Wrap buttons with ProtectedButton
- [ ] Wrap sections with FeatureGated
- [ ] Set up backend validation
- [ ] Configure tier features
- [ ] Test paywall modals
- [ ] Test usage tracking
- [ ] Add analytics events
- [ ] Test on mobile
- [ ] Test upgrade flow

---

**Last Updated**: 2026-01-08  
**Version**: 1.0.0  
**Status**: Production Ready
