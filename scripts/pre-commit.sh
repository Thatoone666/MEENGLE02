#!/bin/bash

# Pre-commit hook for Meengle
# This script runs before each commit to ensure code quality

set -e

echo "Running pre-commit checks..."

# Check if files are staged
STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
    echo "No staged files found"
    exit 0
fi

# Run linting on staged files
echo "[*] Linting staged files..."

FRONTEND_FILES=$(echo "$STAGED_FILES" | grep -E 'frontend/.*\.(js|vue|jsx|ts|tsx)$' || true)
if [ ! -z "$FRONTEND_FILES" ]; then
    cd frontend
    npx eslint $FRONTEND_FILES --max-warnings 5 || {
        echo "[ERROR] Frontend linting failed"
        exit 1
    }
    cd ..
fi

BACKEND_FILES=$(echo "$STAGED_FILES" | grep -E 'backend/.*\.js$' || true)
if [ ! -z "$BACKEND_FILES" ]; then
    cd backend
    npx eslint $BACKEND_FILES --max-warnings 5 || {
        echo "[ERROR] Backend linting failed"
        exit 1
    }
    cd ..
fi

echo "[OK] Pre-commit checks passed"
exit 0
