#!/bin/bash

# MoomHe Firebase Functions Deployment Script

echo "🚀 Deploying MoomHe Firebase Functions..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase. Please run:"
    echo "firebase login"
    exit 1
fi

# Navigate to functions directory
cd functions

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from example..."
    cp .env.example .env
    echo "📝 Please edit functions/.env and add your GEMINI_API_KEY"
    echo "Then run this script again."
    exit 1
fi

# Deploy functions
echo "🚀 Deploying functions..."
firebase deploy --only functions

echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. Update your client code to use the new AI service"
echo "2. Test the functions with a sample request"
echo "3. Monitor usage in Firebase Console"
