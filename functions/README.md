# MoomHe Firebase Functions

This directory contains Firebase Cloud Functions for secure AI image processing.

## Setup

1. Install dependencies:
```bash
cd functions
npm install
```

2. Set up environment variables:
```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your Gemini API key
GEMINI_API_KEY=your_gemini_api_key_here
```

3. Deploy the functions:
```bash
firebase deploy --only functions
```

## Functions

### processImageRequest
- **Trigger**: Firestore document creation in `userHistory` collection
- **Purpose**: Processes AI image generation and object detection requests
- **Features**:
  - User authentication validation
  - Monthly generation count tracking
  - Rate limiting (50 generations per month per user)
  - Secure API key handling
  - Image storage and thumbnail generation

## Security Features

- ✅ API keys stored securely on server
- ✅ User authentication required
- ✅ Rate limiting per user per month
- ✅ Request validation and sanitization
- ✅ Error handling and logging
- ✅ Cost control through usage limits

## Usage Limits

- Default: 50 generations per month per user
- Configurable per user in `genCount/{month-year}/users/{userId}`
- Server automatically tracks and enforces limits
