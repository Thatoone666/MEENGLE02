# ?? MEENGLE Deployment Guide

This guide covers deployment options for MEENGLE.

## ?? Table of Contents
1. [GitHub Pages Deployment](#github-pages-deployment)
2. [Environment Setup](#environment-setup)
3. [CI/CD Pipeline](#cicd-pipeline)
4. [Deployment Checklist](#deployment-checklist)

---

## GitHub Pages Deployment

### Automatic Deployment (Recommended)

The GitHub Actions workflow automatically deploys to GitHub Pages on every push to `main`:

1. **Push to main**
```bash
git add .
git commit -m "Deploy: Version 5.2.0"
git push origin main
```

2. **GitHub Actions runs automatically**
   - Checks out code
   - Installs dependencies
   - Builds frontend
   - Deploys to GitHub Pages

3. **View your site**
   - URL: `https://thusoweb.github.io/MEENGLE1`
   - Wait 1-2 minutes for deployment to complete

### Manual Deployment (Alternative)

If you need to deploy manually:

```bash
# 1. Build the project
cd frontend
npm run build

# 2. Copy dist files
cp -r pages/* ../dist/
cp -r assets/* ../dist/

# 3. Push dist to gh-pages branch
git add dist -f
git commit -m "Deploy to GitHub Pages"
git push origin main
```

---

## Environment Setup

### 1. Firebase Configuration

Create `.env` file in `frontend/` directory:

```env
# Firebase
REACT_APP_FIREBASE_API_KEY=your_api_key
REACT_APP_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=your_project_id
REACT_APP_FIREBASE_STORAGE_BUCKET=your_bucket.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
REACT_APP_FIREBASE_APP_ID=your_app_id

# Stripe
REACT_APP_STRIPE_PUBLIC_KEY=pk_live_your_key

# API
REACT_APP_API_URL=https://api.meengle.app
```

### 2. Secrets Configuration

Go to GitHub Settings ? Secrets and add:

```
FIREBASE_API_KEY
FIREBASE_AUTH_DOMAIN
FIREBASE_PROJECT_ID
FIREBASE_STORAGE_BUCKET
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_APP_ID
STRIPE_PUBLIC_KEY
API_URL
```

### 3. GitHub Pages Settings

1. Go to Repository Settings
2. Navigate to "Pages"
3. Set source to `gh-pages` branch
4. Save changes

---

## CI/CD Pipeline

### GitHub Actions Workflow

File: `.github/workflows/build-deploy.yml`

**Triggers:**
- Push to `main` branch
- Pull requests to `main` branch

**Steps:**
1. ? Checkout code
2. ? Setup Node.js 18
3. ? Install dependencies
4. ? Build frontend
5. ? Deploy to GitHub Pages (on main push only)

**Logs:**
View build logs in Actions tab of repository

---

## Deployment Checklist

### Pre-Deployment

- [ ] All tests passing
- [ ] No console errors
- [ ] All features tested on mobile
- [ ] Accessibility verified (WCAG AA)
- [ ] Performance verified (60FPS)
- [ ] Environment variables set
- [ ] No hardcoded secrets in code
- [ ] Documentation updated

### During Deployment

- [ ] GitHub Actions workflow running
- [ ] No errors in build logs
- [ ] Build completed successfully
- [ ] Deployment to gh-pages successful

### Post-Deployment

- [ ] Visit `https://thusoweb.github.io/MEENGLE1`
- [ ] Test all features in live environment
- [ ] Check console for errors (F12)
- [ ] Test on different devices/browsers
- [ ] Verify API connections working
- [ ] Check Firebase operations
- [ ] Verify Stripe integration
- [ ] Monitor performance metrics

---

## Troubleshooting

### Build Fails

**Problem:** GitHub Actions build fails
**Solution:**
1. Check build logs in Actions tab
2. Verify package.json scripts
3. Check for missing dependencies: `npm install`
4. Verify no git conflicts

### Page Not Updating

**Problem:** Changes not showing on deployed site
**Solution:**
1. Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
2. Clear browser cache
3. Wait 2-3 minutes for GitHub to update
4. Check GitHub Pages status in repository settings

### Firebase Not Working

**Problem:** Firebase errors after deployment
**Solution:**
1. Verify `.env` variables match Firebase config
2. Check Firebase Security Rules
3. Enable CORS if using API
4. Verify Firebase project is active

### Stripe Integration Issues

**Problem:** Stripe payments not working
**Solution:**
1. Verify `STRIPE_PUBLIC_KEY` in `.env`
2. Check Stripe key is for correct environment
3. Verify webhook URL in Stripe dashboard
4. Check browser console for errors

---

## Performance Optimization

### Before Deployment

```bash
# Build with optimizations
npm run build

# Analyze bundle size
npm run analyze
```

### Asset Optimization

- [ ] Images compressed
- [ ] CSS minified
- [ ] JavaScript minified
- [ ] Sourcemaps generated (for debugging)

### CDN Configuration

For faster delivery, consider:
- GitHub Pages built-in CDN ? (Free)
- Cloudflare CDN (Better performance)
- AWS CloudFront (Enterprise)

---

## Monitoring & Analytics

### Setup Analytics

1. Add Google Analytics ID to environment
2. Firebase Analytics automatically tracks events
3. Monitor performance in Firebase Console

### Key Metrics to Monitor

- Page load time
- Time to Interactive
- API response times
- Error rates
- User engagement metrics

---

## Rollback Procedure

If deployment causes issues:

```bash
# Find previous commit
git log --oneline

# Revert to previous version
git revert <commit-hash>
git push origin main

# GitHub Actions will redeploy
```

---

## Security Considerations

### Before Going Live

- [ ] No API keys in code
- [ ] All secrets in GitHub Secrets
- [ ] HTTPS enabled (GitHub Pages default)
- [ ] Security headers configured
- [ ] CORS properly configured
- [ ] Input validation implemented
- [ ] XSS protection enabled
- [ ] CSRF tokens used

### Ongoing Security

- [ ] Regular dependency updates
- [ ] Monitor for vulnerabilities
- [ ] Audit GitHub Actions logs
- [ ] Review access permissions
- [ ] Enable 2FA for GitHub account

---

## Backend Deployment

If deploying backend separately:

### Option 1: Firebase Functions

```bash
firebase deploy --only functions
```

### Option 2: Railway.app

```bash
npm install -g railway
railway link
railway deploy
```

### Option 3: Render

Push to GitHub, Render auto-deploys on push

---

## Custom Domain

To use a custom domain (e.g., meengle.app):

1. **Buy domain** from registrar (GoDaddy, Namecheap, etc.)
2. **Point DNS to GitHub Pages**
   - Add A record: `185.199.108.153`
   - Or add CNAME: `thusoweb.github.io`
3. **Update GitHub Pages settings**
   - Settings ? Pages ? Custom domain
   - Enter: `meengle.app`
4. **Enable HTTPS**
   - Check "Enforce HTTPS"

---

## Support

Need help with deployment?

- ?? [GitHub Pages Docs](https://pages.github.com)
- ?? [Firebase Deployment](https://firebase.google.com)
- ?? [GitHub Actions Docs](https://docs.github.com/en/actions)

---

**Happy Deploying! ??**
