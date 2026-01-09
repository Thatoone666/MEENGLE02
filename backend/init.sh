#!/bin/bash

echo "?? MEENGLE BACKEND STARTUP"

if [ ! -f ".env" ]; then
  echo "??  .env file not found. Creating from .env.example..."
  cp .env.example .env
  echo "? .env created. Please edit it with your values."
fi

echo "?? Installing dependencies..."
npm install

echo "???  Initializing database indexes..."
node seed.js

echo "? All systems initialized. Starting server..."
npm start
