# Backend API - AI Placement Readiness Analyzer

Flask backend server for the AI Placement Readiness & Skill Gap Analyzer application.

## Setup Instructions

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment Variables

1. Copy `.env.example` to `.env`
2. Fill in your API keys:

```env
GEMINI_API_KEY=your_gemini_api_key_here
FIREBASE_CREDENTIALS_PATH=path/to/firebase-service-account.json
FLASK_ENV=development
FLASK_PORT=5000
```

### 3. Get Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy it to your `.env` file

### 4. Setup Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Firestore Database
4. Go to Project Settings > Service Accounts
5. Click "Generate New Private Key"
6. Save the JSON file and update `FIREBASE_CREDENTIALS_PATH` in `.env`

### 5. Run the Server

```bash
python app.py
```

The server will start on `http://localhost:5000`

## API Endpoints

### POST /analyze

Analyze student profile and return readiness assessment.

**Request Body:**
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

**Response:**
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

### GET /health

Health check endpoint.

### GET /history/<student_id>

Get analysis history for a student (simplified - implement proper auth in production).

## Error Handling

All endpoints return appropriate HTTP status codes:
- 200: Success
- 400: Bad Request (validation errors)
- 500: Internal Server Error
- 503: Service Unavailable (Firebase/Gemini not configured)

