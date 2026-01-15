# ?? GitHub Authentication Setup

## The Issue
You got a `Permission denied` error when pushing. This is because GitHub needs to authenticate you.

## Quick Fix (Choose One)

### Option 1: Use GitHub CLI (Recommended) ?
```bash
# 1. Download GitHub CLI from: https://cli.github.com/
# 2. Install it
# 3. Run this command:
gh auth login

# Follow the prompts:
# - Select: GitHub.com
# - Select: HTTPS
# - Authenticate with browser
```

After this, your Git commands will work automatically.

### Option 2: Personal Access Token (Alternative)
```bash
# 1. Go to GitHub: https://github.com/settings/tokens
# 2. Click "Generate new token"
# 3. Select scopes:
#    - repo (full control)
#    - workflow
# 4. Copy the token
# 5. Run:
git push https://<YOUR_TOKEN>@github.com/Thusoweb/MEENGLE1.git main
```

### Option 3: SSH Key (Most Secure)
```bash
# 1. Generate SSH key
ssh-keygen -t ed25519 -C "your-email@example.com"

# 2. Add to SSH agent (Windows PowerShell):
ssh-add $env:USERPROFILE\.ssh\id_ed25519

# 3. Copy public key to GitHub:
#    - Go to: https://github.com/settings/keys
#    - Click "New SSH key"
#    - Paste contents of: C:\Users\thusowaver\.ssh\id_ed25519.pub

# 4. Update Git remote to use SSH:
git remote set-url origin git@github.com:Thusoweb/MEENGLE1.git

# 5. Push
git push origin main
```

---

## After Authentication

You can now push your changes:

```bash
cd "C:\Users\thusowaver\Desktop\Coding Mingle"
git push origin main
```

---

## Troubleshooting

### "Still getting permission error?"
- Check that you're pushing with the correct user account
- Make sure you're a collaborator on the repository
- If using token, verify it hasn't expired

### "Don't know GitHub username?"
```bash
git config user.name
git config user.email
```

### "Need to update Git credentials?"
Windows: Go to Settings ? Credential Manager ? Generic Credentials ? Find GitHub

---

## Next Steps

Once authenticated:

1. ? Push your changes: `git push origin main`
2. ? Go to https://github.com/Thusoweb/MEENGLE1
3. ? Go to Actions tab to see your workflow run
4. ? Wait 2-3 minutes for build and deploy
5. ? Visit `https://thusoweb.github.io/MEENGLE1` to see your site!

---

**Recommended: Use GitHub CLI - it's the easiest! ??**
