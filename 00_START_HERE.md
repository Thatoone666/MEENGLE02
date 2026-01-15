# ?? GitHub Authentication & Deployment Guide

## Problem You're Facing

When you tried to `git push`, you got:
```
fatal: unable to access 'https://github.com/Thusoweb/MEENGLE1.git/': The requested URL returned error: 403
```

This means GitHub needs to authenticate you before you can push code.

---

## ? Solution: 3 Options

### **Option 1: GitHub CLI (BEST - Recommended) ?**

This is the easiest and most secure method.

#### Step 1: Install GitHub CLI
- Download from: https://cli.github.com/
- Run the installer
- Follow the setup wizard

#### Step 2: Authenticate
```powershell
gh auth login
```

Follow the prompts:
- Select: `GitHub.com`
- Select: `HTTPS`
- Approve request to continue: `Authorize`
- When asked about credentials: `Paste an authentication token`
- Login in browser when prompted

#### Step 3: Test It Works
```powershell
cd "C:\Users\thusowaver\Desktop\Coding Mingle"
git push origin main
```

? **That's it! You're done!**

---

### **Option 2: Personal Access Token**

If GitHub CLI doesn't work for you.

#### Step 1: Create Token on GitHub
1. Go to: https://github.com/settings/tokens
2. Click: "Generate new token" ? "Generate new token (classic)"
3. Give it a name: `MEENGLE Deployment`
4. Select scopes:
   - ? `repo` (full control)
   - ? `workflow`
5. Click: "Generate token"
6. **Copy the token** (you won't see it again!)

#### Step 2: Use Token to Push
```powershell
cd "C:\Users\thusowaver\Desktop\Coding Mingle"
git push https://YOUR_TOKEN@github.com/Thusoweb/MEENGLE1.git main
```

Replace `YOUR_TOKEN` with the token you copied.

#### Step 3: (Optional) Save Token for Future
To avoid typing the token every time, use Git credential storage:
```powershell
git config --global credential.helper wincred
# Then use: git push origin main
```

---

### **Option 3: SSH Key (Most Secure)**

For advanced users.

#### Step 1: Generate SSH Key
```powershell
ssh-keygen -t ed25519 -C "your-email@example.com"
```
- Press Enter for all prompts (use default location)
- Don't set a passphrase (or set one if you prefer)

#### Step 2: Add Key to SSH Agent
```powershell
# Start SSH agent
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent

# Add your key
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

#### Step 3: Add Public Key to GitHub
1. Copy public key:
```powershell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | Set-Clipboard
```

2. Go to: https://github.com/settings/keys
3. Click: "New SSH key"
4. Paste the key
5. Click: "Add SSH key"

#### Step 4: Update Git Remote
```powershell
git remote set-url origin git@github.com:Thusoweb/MEENGLE1.git
```

#### Step 5: Test It
```powershell
cd "C:\Users\thusowaver\Desktop\Coding Mingle"
git push origin main
```

---

## ?? After Authentication

Once authenticated, you can push your code:

```powershell
cd "C:\Users\thusowaver\Desktop\Coding Mingle"
git add .
git commit -m "Setup: GitHub Pages deployment configuration"
git push origin main
```

### What Happens Next:

1. ? Code pushed to GitHub
2. ? GitHub Actions starts automatically
3. ? Builds your frontend
4. ? Deploys to GitHub Pages
5. ? Available at: https://thusoweb.github.io/MEENGLE1

**?? Takes 2-3 minutes total**

---

## ?? Verify It's Working

### View Build Status:
1. Go to: https://github.com/Thusoweb/MEENGLE1
2. Click: "Actions" tab
3. See your workflow running

### When Complete:
- Look for **green checkmark** ?
- Visit: https://thusoweb.github.io/MEENGLE1
- Your site is live!

---

## ? Troubleshooting

### "Still getting permission error?"
- Make sure you completed all steps
- Try closing and reopening terminal
- If using token: make sure you copied it correctly
- If using SSH: verify key was added to GitHub

### "How do I know which option worked?"
Try pushing with: `git push origin main`
- If it works ? you're authenticated! ??
- If it fails ? try the next option

### "Lost my token?"
Generate a new one at: https://github.com/settings/tokens

### "Need to check my current Git config?"
```powershell
git config user.name
git config user.email
git config --list
```

---

## ?? Recommended: Use GitHub CLI

- ? Easiest to set up
- ? Most secure
- ? Best long-term solution
- ? Works for all Git operations
- ? Updates automatically

---

## ?? Quick Reference

| Task | Command |
|------|---------|
| Authenticate | `gh auth login` |
| Push code | `git push origin main` |
| Check status | `git status` |
| View commits | `git log --oneline` |
| Pull updates | `git pull origin main` |

---

## ?? Next Steps After Authentication

```bash
# 1. Verify you're authenticated
git status

# 2. Push your code
git push origin main

# 3. Watch the build
# Go to: https://github.com/Thusoweb/MEENGLE1/actions

# 4. Visit your live site
# Go to: https://thusoweb.github.io/MEENGLE1
```

---

## ? Checklist

- [ ] Downloaded GitHub CLI or have another auth method ready
- [ ] Completed authentication steps
- [ ] Can run `git push origin main` without errors
- [ ] Saw "workflow triggered" or similar message
- [ ] Checked Actions tab on GitHub
- [ ] Waited 2-3 minutes for build to complete
- [ ] Visited live site at https://thusoweb.github.io/MEENGLE1

---

**Pick Option 1 (GitHub CLI) and you'll be done in 5 minutes! ??**

Questions? Check the other documentation files or ask on GitHub Discussions.
