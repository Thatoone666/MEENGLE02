# ?? MEENGLE - Social Connection Platform

> **The App That Brings People Together - Find Friends, Activities & Connections in Real-Time**

![Version](https://img.shields.io/badge/version-5.2.0-blue.svg)
![Status](https://img.shields.io/badge/status-PRODUCTION%20READY-green.svg)
![Performance](https://img.shields.io/badge/performance-60FPS-brightgreen.svg)
![Accessibility](https://img.shields.io/badge/accessibility-WCAG%20AA-blue.svg)

---

## ?? What is MEENGLE?

MEENGLE is a comprehensive social platform that helps people discover, connect, and experience together through:

- **?? Real-Time Check-Ins** - Share your location and what you're doing
- **?? Meengling (Swiping)** - Discover compatible people nearby
- **?? Activity Planning** - Organize and join group activities
- **?? Direct Messaging** - Connect with matches and friends
- **?? Premium Tiers** - Flexible subscription levels for all users

---

## ? Core Features

### 1. Check-In System ??
- 15 check-in types (Hotel, Restaurant, Club, Beach, etc.)
- 5 status options (Looking, Chilling, Party, Gaming, Studying)
- 4 visibility levels (Public, Friends, Private, Hidden)
- Real-time location-based discovery
- User ratings and profiles

### 2. Meengling (Profile Swiping) ??
- Smooth card-based swiping interface
- Like/Pass interactions
- Interest-based matching algorithm
- Distance-based filtering
- Real-time match notifications

### 3. Activity Planning System ??
- 20+ activity categories
- Full activity lifecycle management
- Participant management & tracking
- Skill-level matching
- Organizer ratings and reviews
- Group chat for activity participants

### 4. Direct Messaging ??
- Real-time message delivery
- Read receipts and message status
- Message history & conversation management
- Block/report functionality
- Video call requests
- Activity sharing between matches

### 5. Premium Tier System ??
- **Free** - Basic features
- **Spark** - Basic recommendations
- **Spark+** - Advanced discovery
- **Flame** - Full messaging access
- **Wildfire** - All features + premium benefits

---

## ??? Project Structure

```
MEENGLE1/
??? frontend/                    # React-based frontend app
?   ??? src/
?   ?   ??? components/          # Reusable UI components (15+)
?   ?   ??? pages/               # Page components (7+)
?   ?   ??? services/            # Business logic (18 services)
?   ?   ??? config/              # Firebase & environment config
?   ?   ??? styles/              # Design system & CSS
?   ??? pages/                   # HTML pages
?   ??? assets/                  # Images, fonts, static files
?   ??? package.json
?   ??? index.html
??? backend/                     # Node.js/Express backend
?   ??? src/
?   ??? routes/
?   ??? package.json
??? .github/workflows/           # CI/CD automation
?   ??? build-deploy.yml         # GitHub Pages deployment
??? docs/                        # Documentation
??? .env.example                 # Environment template
??? README.md                    # This file
```

---

## ?? Getting Started

### Prerequisites
- Node.js 18+ 
- npm or yarn
- Firebase account (for backend services)
- Stripe account (for payments)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Thusoweb/MEENGLE1.git
cd MEENGLE1
```

2. **Setup environment variables**
```bash
cp .env.example .env.local
# Edit .env.local with your Firebase and Stripe keys
```

3. **Install frontend dependencies**
```bash
cd frontend
npm install
```

4. **Build the frontend**
```bash
npm run build
```

5. **Start development server**
```bash
npm start
```

Visit `http://localhost:3000` in your browser.

---

## ?? Available Scripts

### Frontend

```bash
# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build

# Run tests
npm test

# Watch for changes (development)
npm run watch
```

### Backend

```bash
# Install dependencies
cd backend && npm install

# Start backend server
npm start

# Start with nodemon (auto-reload)
npm run dev
```

---

## ?? Design System

### Color Palette
- **Primary**: `#ff6b6b` (Vibrant Red)
- **Secondary**: `#2196f3` (Blue)
- **Success**: `#4caf50` (Green)
- **Error**: `#f44336` (Red)

### Typography
- **H1**: 32px, 700 weight
- **H2**: 28px, 700 weight
- **H3**: 24px, 700 weight
- **Body**: 14px, 400 weight

### Spacing
- 4px base grid system
- Consistent 16 spacing scales throughout

### Shadows
- 7 elevation levels
- Professional appearance with smooth transitions

---

## ? Performance

- **?? 60FPS Smooth** - All animations optimized for 60FPS
- **?? 14 GPU-Accelerated Animations** - Fade, Slide, Scale, Rotate, Pulse, Bounce, Shake, Shimmer
- **?? Lazy Loading** - Images load on demand
- **?? Optimized Debounce/Throttle** - Reduced unnecessary operations
- **?? Mobile-First** - Responsive design for all devices

---

## ?? Security Features

- ? Firebase Authentication
- ? Firestore Security Rules
- ? HTTPS only
- ? Secure payment with Stripe
- ? User privacy controls
- ? Block/Report functionality

---

## ?? Responsive Design

| Screen | Breakpoint | Features |
|--------|-----------|----------|
| Mobile | < 480px | Bottom nav, Full-width, Touch-optimized |
| Tablet | 480-768px | Optimized spacing, Two-column layouts |
| Desktop | > 768px | Side nav, Multi-column, Hover states |

---

## ??? Tech Stack

### Frontend
- **React** - UI library
- **CSS3** - Styling with modern features
- **Firebase SDK** - Real-time database & auth
- **Stripe.js** - Payment processing

### Backend
- **Node.js** - Runtime environment
- **Express** - Web framework
- **Firebase Admin SDK** - Backend integration
- **Stripe API** - Payment webhooks

### Database & Services
- **Firebase Firestore** - Real-time database
- **Firebase Authentication** - User management
- **Firebase Storage** - Photo uploads
- **Stripe** - Payment processing

---

## ?? Documentation

Comprehensive documentation is available in the `/docs` directory:

- `UI_UX_COMPLETE_REDESIGN.md` - Full UI/UX redesign guide
- `PERFORMANCE_AND_POLISH.md` - Performance optimization
- `CHECK_IN_FEATURE.md` - Check-in system guide
- `ACTIVITY_PLANNING_SYSTEM.md` - Activity system guide
- `DIRECT_MESSAGING_SYSTEM.md` - Messaging guide
- `PAYWALL_SYSTEM.md` - Subscription tiers guide

---

## ?? Deployment

### GitHub Pages (Frontend)
The frontend is automatically built and deployed to GitHub Pages on every push to `main`:

```bash
git push origin main
```

GitHub Actions will:
1. ? Checkout code
2. ? Install dependencies
3. ? Build the project
4. ? Deploy to GitHub Pages

View live at: `https://thusoweb.github.io/MEENGLE1`

### Environment Variables

Create `.env` file in frontend root:
```env
REACT_APP_FIREBASE_API_KEY=your_key
REACT_APP_FIREBASE_AUTH_DOMAIN=your_domain
REACT_APP_FIREBASE_PROJECT_ID=your_project_id
REACT_APP_FIREBASE_STORAGE_BUCKET=your_bucket
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
REACT_APP_FIREBASE_APP_ID=your_app_id
REACT_APP_STRIPE_PUBLIC_KEY=your_stripe_key
```

---

## ?? Quality Assurance

- ? **60FPS Validation** - All animations tested for smoothness
- ? **WCAG AA Accessibility** - Full accessibility compliance
- ? **Responsive Testing** - Tested on mobile, tablet, desktop
- ? **Error Handling** - Comprehensive error boundaries
- ? **Performance Optimized** - Lazy loading, code splitting

---

## ?? Code Statistics

```
? 19 Components
? 19 CSS Files
? 18 Service Modules
? 9,500+ Lines of Code
? 60FPS Smooth Animations
? Professional Shadows
? WCAG AA Compliant
? Production Ready
```

---

## ?? Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## ?? License

This project is proprietary and confidential. All rights reserved.

---

## ?? Support

For issues, feature requests, or questions:

- ?? Email: support@meengle.app
- ?? GitHub Issues: [Report a bug](https://github.com/Thusoweb/MEENGLE1/issues)
- ?? Discussions: [Ask a question](https://github.com/Thusoweb/MEENGLE1/discussions)

---

## ?? Roadmap

### Q1 2026
- [ ] Android app launch
- [ ] iOS app launch
- [ ] Push notifications
- [ ] Video messaging

### Q2 2026
- [ ] AI-powered recommendations
- [ ] Group activity features
- [ ] Advanced analytics
- [ ] Admin dashboard

### Q3 2026
- [ ] Social verification
- [ ] Premium content
- [ ] Sponsored activities
- [ ] Partnership program

---

## ?? Credits

Built with ?? by the MEENGLE Team

---

## ? Deployment Checklist

- [x] All components built
- [x] Full responsive design
- [x] Accessibility tested
- [x] Performance optimized
- [x] 60FPS verified
- [x] Shadows applied
- [x] Animations smooth
- [x] Documentation complete
- [x] Error handling
- [x] Loading states
- [x] GitHub Actions setup
- [x] GitHub Pages ready

---

**Status**: ?? **PRODUCTION READY**  
**Version**: 5.2.0  
**Last Updated**: January 8, 2026  

**Ready to launch! ??**
