#!/bin/bash
# Simple test script - verify backend can start

cd "C:\Users\thusowaver\Desktop\Coding Mingle\backend"
echo "Starting Meengle Backend Server..."
echo "Port: 3001"
echo ""
echo "Health check: curl http://localhost:3001/health"
echo ""

npm start
