# AI Placement Readiness & Skill Gap Analyzer

A production-ready full-stack application that helps students evaluate their placement preparation, identify skill gaps, and receive personalized improvement plans using ethical AI analysis.

## 🎯 Overview

This application provides:
- **Objective Readiness Assessment**: Calculates a Placement Readiness Score (0-100) based on multiple factors
- **Skill Gap Analysis**: Identifies strengths, weaknesses, and risk factors
- **Personalized 30-Day Plan**: Week-wise improvement roadmap
- **Progress Tracking**: Stores analysis history in Firebase for tracking improvements over time

### ⚠️ Ethical Guidelines

This system **MUST NOT**:
- Predict placement outcomes
- Mention specific companies or recruiters
- Make hiring guarantees
- Use personal data unethically

The AI focuses on **skill development** and **continuous improvement** only.

## 🏗️ Architecture

```
Flutter App (Frontend)
    ↓ HTTP Request
Flask API (Backend)
    ↓ API Call
Gemini AI (Analysis)
    ↓ Store Results
Firebase Firestore (Database)
```

## 📦 Tech Stack

- **Frontend**: Flutter (Material 3)
- **Backend**: Python Flask
- **AI**: Google Gemini API
- **Database**: Firebase Firestore

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Flutter SDK 3.0+
- Google Gemini API Key
- Firebase Project with Firestore enabled

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment variables**:
   
   Create a `.env` file in the `backend` directory:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   FIREBASE_CREDENTIALS_PATH=path/to/firebase-service-account.json
   FLASK_ENV=development
   FLASK_PORT=5000
   ```

4. **Get Gemini API Key**:
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key
   - Add it to your `.env` file

5. **Setup Firebase**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Firestore Database
   - Go to Project Settings > Service Accounts
   - Generate new private key (JSON file)
   - Save the JSON file and update `FIREBASE_CREDENTIALS_PATH` in `.env`

6. **Run the backend server**:
   ```bash
   python app.py
   ```

   The server will start on `http://localhost:5000`

### Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Update API URL** (if needed):
   
   Edit `lib/services/api_service.dart` and update the `baseUrl` if your backend is running on a different host/port.

4. **Run the Flutter app**:
   ```bash
   flutter run
   ```

## 📱 App Flow

1. **Input Screen**: Student enters their profile data:
   - Attendance percentage
   - CGPA range
   - DSA practice frequency
   - Number of technical projects
   - Internship experience
   - Mock interview score
   - Resume completeness score

2. **Analysis**: Click "Analyze Readiness" button
   - Data is sent to Flask backend
   - Backend calls Gemini API for analysis
   - Results are stored in Firebase
   - Analysis results are returned to app

3. **Results Screen**: View comprehensive analysis:
   - Readiness Score (0-100) with visual progress indicator
   - Readiness Level (Low/Medium/High)
   - Summary explanation
   - Strengths list
   - Areas for improvement
   - Risk factors
   - Recommendations
   - 30-day improvement plan (week-wise)

## 🗄️ Firebase Data Schema

### Collection: `student_analyses`

**Document Structure**:
```json
{
  "student_profile": {
    "attendance": 85,
    "cgpa_range": "7-8",
    "dsa_practice": 5,
    "projects": 3,
    "internship": "Short",
    "mock_interview": 75,
    "resume_score": 80
  },
  "analysis": {
    "readiness_score": 72,
    "readiness_level": "Medium",
    "summary": "...",
    "strengths": ["..."],
    "weak_areas": ["..."],
    "risk_factors": ["..."],
    "recommendations": ["..."],
    "30_day_plan": {
      "week_1": {
        "focus": "...",
        "tasks": ["..."]
      },
      ...
    }
  },
  "timestamp": "2024-01-15T10:30:00",
  "readiness_score": 72,
  "readiness_level": "Medium"
}
```

## 🧪 Sample Test Data

### Sample Student Profile 1 (High Readiness)
```json
{
  "attendance": 95,
  "cgpa_range": "8-9",
  "dsa_practice": 7,
  "projects": 5,
  "internship": "Long",
  "mock_interview": 85,
  "resume_score": 90
}
```

### Sample Student Profile 2 (Medium Readiness)
```json
{
  "attendance": 80,
  "cgpa_range": "7-8",
  "dsa_practice": 4,
  "projects": 3,
  "internship": "Short",
  "mock_interview": 70,
  "resume_score": 75
}
```

### Sample Student Profile 3 (Low Readiness)
```json
{
  "attendance": 60,
  "cgpa_range": "6-7",
  "dsa_practice": 1,
  "projects": 1,
  "internship": "None",
  "mock_interview": 50,
  "resume_score": 60
}
```

## 🔌 API Endpoints

### POST `/analyze`

Analyze student profile and return readiness assessment.

**Request**:
```json
{
  "attendance": 85,
  "cgpa_range": "7-8",
  "dsa_practice": 5,
  "projects": 3,
  "internship": "Short",
  "mock_interview": 75,
  "resume_score": 80
}
```

**Response**:
```json
{
  "success": true,
  "analysis": {
    "readiness_score": 72,
    "readiness_level": "Medium",
    "summary": "...",
    "strengths": [...],
    "weak_areas": [...],
    "risk_factors": [...],
    "recommendations": [...],
    "30_day_plan": {...}
  },
  "document_id": "uuid-here"
}
```

### GET `/health`

Health check endpoint.

**Response**:
```json
{
  "status": "healthy",
  "gemini_configured": true,
  "firebase_configured": true
}
```

### GET `/history/<student_id>`

Get analysis history (simplified - implement proper auth in production).

## 🎨 UI Features

- **Material 3 Design**: Modern, clean interface
- **Color-coded Readiness Levels**:
  - 🟢 High: Green
  - 🟠 Medium: Orange
  - 🔴 Low: Red
- **Progress Indicators**: Circular progress for readiness score
- **Card-based Layout**: Organized information display
- **Week-wise Plan Cards**: Color-coded weekly improvement tasks

## 🛡️ AI Safety & Ethics

The Gemini system prompt is designed to:
- Focus on skill development, not predictions
- Provide transparent, explainable reasoning
- Emphasize continuous learning and growth
- Avoid making guarantees or promises
- Use objective, constructive feedback

## 📝 Project Structure

```
.
├── backend/
│   ├── app.py                 # Flask API server
│   ├── requirements.txt       # Python dependencies
│   └── README.md             # Backend documentation
├── frontend/
│   ├── lib/
│   │   ├── main.dart         # App entry point
│   │   ├── models/           # Data models
│   │   ├── screens/          # UI screens
│   │   └── services/         # API service
│   └── pubspec.yaml          # Flutter dependencies
└── README.md                  # This file
```

## 🐛 Troubleshooting

### Backend Issues

1. **Gemini API Error**:
   - Verify `GEMINI_API_KEY` is set correctly in `.env`
   - Check API key is valid and has quota

2. **Firebase Error**:
   - Verify `FIREBASE_CREDENTIALS_PATH` points to valid JSON file
   - Ensure Firestore is enabled in Firebase Console
   - Check service account has proper permissions

3. **Port Already in Use**:
   - Change `FLASK_PORT` in `.env` to a different port

### Frontend Issues

1. **Cannot Connect to Backend**:
   - Verify backend is running on correct port
   - Update `baseUrl` in `api_service.dart` if needed
   - Check CORS is enabled in Flask (already configured)

2. **Build Errors**:
   - Run `flutter pub get` to install dependencies
   - Ensure Flutter SDK version is 3.0+

## 🚀 Production Deployment

### Backend Deployment

1. Use a production WSGI server (e.g., Gunicorn)
2. Set up proper environment variables
3. Configure HTTPS
4. Implement authentication/authorization
5. Add rate limiting
6. Set up monitoring and logging

### Frontend Deployment

1. Build release APK/IPA:
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```
2. Update API URL to production endpoint
3. Configure app signing
4. Publish to app stores

## 📄 License

This project is created for educational and hackathon purposes.

## 🤝 Contributing

This is a hackathon project. Feel free to extend and improve:
- Add more analysis factors
- Implement user authentication
- Add progress tracking visualization
- Enhance UI/UX
- Add export functionality

## 📧 Support

For issues or questions, please refer to the documentation or create an issue in the repository.

---

**Built with ❤️ for ethical AI in education**


