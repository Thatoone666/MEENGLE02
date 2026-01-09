# ?? GitHub Setup Instructions for Meengle

## Step 1: Create GitHub Account (if you don't have one)
- Go to https://github.com
- Sign up with email
- Verify email address

## Step 2: Create New Repository on GitHub

1. Go to https://github.com/new
2. Fill in repository details:
   - **Repository name**: `meengle`
   - **Description**: Complete social platform combining dating, location-based check-ins, activity planning, and real-time messaging
   - **Public/Private**: Public (for open source) or Private (for closed source)
   - **Add .gitignore**: Select "Node"
   - **Add license**: Select "MIT"

3. Click **Create repository**

## Step 3: Initialize Local Repository

### On Windows (PowerShell):

```powershell
# Navigate to your Meengle directory
cd "C:\Users\thusowaver\Desktop\Coding Mingle"

# Initialize git
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Create .gitignore (see file below)
# Create README.md (see file below)
# Create LICENSE (see file below)

# Stage files
git add .

# Create first commit
git commit -m "Initial commit: Meengle - Complete social platform"
```

### On Mac/Linux:

```bash
cd ~/path/to/meengle
bash setup-github.sh
```

## Step 4: Connect to GitHub

Replace `YOUR_USERNAME` with your GitHub username:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/meengle.git
git branch -M main
git push -u origin main
```

## Step 5: Verify on GitHub

1. Go to your GitHub repository
2. You should see all your files uploaded
3. Check that README.md displays correctly

## Step 6: Clone to Test

To verify everything works, clone your repository:

```powershell
cd C:\temp
git clone https://github.com/YOUR_USERNAME/meengle.git
cd meengle
```

## Step 7: Setup Project Locally

### Install Dependencies

```powershell
# Frontend
cd frontend
npm install
npm start

# In another terminal - Backend
cd backend
npm install
npm start
```

## Step 8: Create Environment Files

### Frontend (.env.local)
```
REACT_APP_FIREBASE_API_KEY=your_key_here
REACT_APP_FIREBASE_AUTH_DOMAIN=your_domain_here
REACT_APP_FIREBASE_PROJECT_ID=your_project_id
REACT_APP_FIREBASE_STORAGE_BUCKET=your_bucket
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
REACT_APP_FIREBASE_APP_ID=your_app_id
REACT_APP_STRIPE_PUBLISHABLE_KEY=your_stripe_key
REACT_APP_API_ENDPOINT=http://localhost:3001
```

### Backend (.env)
```
STRIPE_SECRET_KEY=your_secret_key
STRIPE_WEBHOOK_SECRET=your_webhook_secret
FRONTEND_URL=http://localhost:3000
PORT=3001
```

## Step 9: Test the Application

### Frontend (Port 3000)
```
http://localhost:3000
```

### Backend (Port 3001)
```
http://localhost:3001/health
```

## Step 10: Deploy to GitHub Pages (Optional)

For static site hosting:

```powershell
npm install gh-pages --save-dev
npm run build
npm run deploy
```

## Git Workflow

### Making Changes

```powershell
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes to files

# Stage changes
git add .

# Commit
git commit -m "feat: Add your feature description"

# Push to GitHub
git push origin feature/your-feature-name
```

### Creating Pull Request

1. Go to your GitHub repository
2. Click "Pull requests"
3. Click "New pull request"
4. Select your feature branch
5. Add description
6. Click "Create pull request"

## Useful Git Commands

```powershell
# View status
git status

# View commit history
git log --oneline

# View branches
git branch -a

# Switch branch
git checkout branch-name

# Create and switch to new branch
git checkout -b new-branch-name

# Merge branch
git merge branch-name

# Delete branch
git branch -d branch-name

# Undo changes
git checkout -- filename

# Reset to last commit
git reset --hard HEAD
```

## GitHub Features to Enable

### In Repository Settings:

1. **Discussions** - Enable for community Q&A
2. **Wiki** - Enable for documentation
3. **Issues** - Already enabled by default
4. **Projects** - Enable for project management
5. **Branch protection** - Protect main branch
   - Require pull request reviews
   - Require status checks
   - Dismiss stale PR approvals

## Adding Collaborators

1. Go to Repository Settings
2. Select "Collaborators"
3. Click "Add people"
4. Enter username/email
5. Select permission level
6. Send invite

## Deployment

### Deploy Frontend to Vercel

```powershell
npm install -g vercel
vercel login
vercel
```

### Deploy Backend to Heroku

```powershell
npm install -g heroku
heroku login
heroku create meengle-api
git push heroku main
```

## Monitoring & Stats

### View on GitHub:

1. **Insights** - See traffic, forks, stars
2. **Network** - View branch history
3. **Security** - Check vulnerabilities
4. **Code frequency** - See activity over time

## Troubleshooting

### Permission Denied (publickey)
```powershell
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to GitHub at Settings > SSH and GPG keys
```

### Push Rejected
```powershell
# Pull latest changes first
git pull origin main

# Then push again
git push origin main
```

### Merge Conflicts
```powershell
# View conflicted files
git status

# Edit files to resolve conflicts

# Mark as resolved
git add resolved-file.js

# Complete merge
git commit -m "Resolve merge conflicts"
```

---

## ? You're Ready!

Your Meengle repository is now on GitHub and ready for:
- Sharing with others
- Continuous integration (GitHub Actions)
- Open source contributions
- Version control and backup
- Team collaboration

?? **Congratulations! Your app is now on GitHub!**

For more help: https://docs.github.com
