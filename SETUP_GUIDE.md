# Setup Guide - Step by Step

This guide will walk you through setting up the AI Placement Readiness Analyzer from scratch.

## Prerequisites Checklist

- [ ] Python 3.8 or higher installed
- [ ] Flutter SDK 3.0 or higher installed
- [ ] Google account (for Gemini API)
- [ ] Google account (for Firebase)
- [ ] Code editor (VS Code recommended)

## Step 1: Clone/Download Project

If using git:
```bash
git clone <repository-url>
cd cursortry
```

Or extract the project files to a directory.

## Step 2: Backend Setup

### 2.1 Navigate to Backend Directory
```bash
cd backend
```

### 2.2 Create Virtual Environment (Recommended)
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### 2.3 Install Dependencies
```bash
pip install -r requirements.txt
```

### 2.4 Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the API key (starts with `AIza...`)

### 2.5 Setup Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" or select existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "placement-analyzer")
   - Disable Google Analytics (optional)
   - Click "Create Project"
4. Enable Firestore:
   - Click "Firestore Database" in left menu
   - Click "Create Database"
   - Select "Start in test mode" (for development)
   - Choose a location
   - Click "Enable"
5. Get Service Account Key:
   - Go to Project Settings (gear icon)
   - Click "Service Accounts" tab
   - Click "Generate New Private Key"
   - Save the JSON file (e.g., `firebase-service-account.json`)
   - **Important**: Keep this file secure and never commit it to git

### 2.6 Create Environment File

Create a file named `.env` in the `backend` directory:

```env
GEMINI_API_KEY=AIzaSyC...your_key_here
FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json
FLASK_ENV=development
FLASK_PORT=5000
```

**Important**: 
- Replace `AIzaSyC...your_key_here` with your actual Gemini API key
- Update `FIREBASE_CREDENTIALS_PATH` to the actual path of your Firebase JSON file
- Make sure the path is relative to the `backend` directory or use absolute path

### 2.7 Test Backend

```bash
python app.py
```

You should see:
```
Firebase initialized successfully
 * Running on http://127.0.0.1:5000
```
y
Open another terminal and test:
```bash
curl http://localhost:5000/health
```

Expected response:
```json
{
  "status": "healthy",
  "gemini_configured": true,
  "firebase_configured": true
}
```

If you see errors:
- **Gemini not configured**: Check your `.env` file and API key
- **Firebase not configured**: Check the credentials path and JSON file

## Step 3: Frontend Setup

### 3.1 Navigate to Frontend Directory

Open a new terminal:
```bash
cd frontend
```

### 3.2 Install Flutter Dependencies

```bash
flutter pub get
```

### 3.3 Verify Backend URL

Open `lib/services/api_service.dart` and verify:
```dart
static const String baseUrl = 'http://localhost:5000';
```

If your backend runs on a different host/port, update this.

### 3.4 Run Flutter App

For Android/iOS emulator:
```bash
flutter run
```

For web (if supported):
```bash
flutter run -d chrome
```

For Windows:
```bash
flutter run -d windows
```

## Step 4: Test the Application

### 4.1 Test Flow

1. **Start Backend**: Make sure Flask server is running
2. **Start Frontend**: Launch Flutter app
3. **Enter Sample Data**:
   - Attendance: 85
   - CGPA Range: 7-8
   - DSA Practice: 5
   - Projects: 3
   - Internship: Short
   - Mock Interview: 75
   - Resume Score: 80
4. **Click "Analyze Readiness"**
5. **View Results**: You should see:
   - Readiness Score
   - Readiness Level
   - Summary
   - Strengths
   - Weak Areas
   - Risk Factors
   - Recommendations
   - 30-Day Plan

### 4.2 Verify Firebase Storage

1. Go to Firebase Console
2. Navigate to Firestore Database
3. You should see a collection `student_analyses`
4. Click on a document to view stored data

## Troubleshooting

### Backend Issues

**Problem**: `ModuleNotFoundError: No module named 'flask'`
- **Solution**: Make sure virtual environment is activated and dependencies are installed

**Problem**: `GEMINI_API_KEY not set`
- **Solution**: Check `.env` file exists and has correct variable name

**Problem**: `Firebase credentials not found`
- **Solution**: Verify `FIREBASE_CREDENTIALS_PATH` points to valid JSON file

**Problem**: `Port 5000 already in use`
- **Solution**: Change `FLASK_PORT` in `.env` to another port (e.g., 5001)

### Frontend Issues

**Problem**: `Cannot connect to backend`
- **Solution**: 
  - Verify backend is running
  - Check `baseUrl` in `api_service.dart`
  - For Android emulator, use `http://10.0.2.2:5000` instead of `localhost`
  - For iOS simulator, use `http://localhost:5000`
  - For physical device, use your computer's IP address (e.g., `http://192.168.1.100:5000`)

**Problem**: `flutter: command not found`
- **Solution**: Install Flutter SDK and add to PATH

**Problem**: Build errors
- **Solution**: Run `flutter clean` then `flutter pub get`

### API Issues

**Problem**: `Gemini API error: API key not valid`
- **Solution**: Regenerate API key from Google AI Studio

**Problem**: `Rate limit exceeded`
- **Solution**: Gemini free tier has limits. Wait a few minutes or upgrade plan

**Problem**: `Invalid JSON response`
- **Solution**: Check Gemini API is returning valid JSON. The prompt should enforce JSON format.

## Development Tips

1. **Backend Logging**: Check Flask console for errors
2. **Frontend Debugging**: Use Flutter DevTools
3. **API Testing**: Use Postman or curl to test endpoints directly
4. **Firebase Console**: Monitor Firestore for data storage

## Next Steps

- Customize the Gemini prompt for your specific needs
- Add user authentication
- Implement progress tracking UI
- Add export functionality
- Deploy to production

## Production Deployment

### Backend
- Use Gunicorn or similar WSGI server
- Set up environment variables on hosting platform
- Configure HTTPS
- Implement proper authentication

### Frontend
- Build release version: `flutter build apk` or `flutter build ios`
- Update API URL to production endpoint
- Configure app signing
- Publish to app stores

---

**Need Help?** Check the main README.md for more details.

