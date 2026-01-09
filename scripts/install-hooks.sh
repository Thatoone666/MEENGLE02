#!/bin/bash

# Install git hooks for Meengle development

HOOKS_DIR=".git/hooks"

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Copy and enable pre-commit hook
if [ -f "scripts/pre-commit.sh" ]; then
    cp scripts/pre-commit.sh "$HOOKS_DIR/pre-commit"
    chmod +x "$HOOKS_DIR/pre-commit"
    echo "[OK] Pre-commit hook installed"
else
    echo "[WARN] Pre-commit hook script not found"
fi

echo "[OK] Git hooks installed"
echo ""
echo "Available hooks:"
echo "  - pre-commit: Runs linting before each commit"
echo ""
echo "To disable a hook temporarily:"
echo "  git commit --no-verify"
