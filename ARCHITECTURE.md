# System Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Frontend                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Input Screen │  │Results Screen│  │  API Service │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTP/REST
                            │ JSON
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Flask Backend API                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  /analyze    │  │  /health     │  │  /history    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└───────────┬───────────────────────────────┬─────────────────┘
            │                               │
            │ API Call                      │ Store Data
            ↓                               ↓
┌──────────────────────┐      ┌──────────────────────────────┐
│   Gemini AI API      │      │   Firebase Firestore         │
│                      │      │                              │
│  - Analysis          │      │  Collection:                 │
│  - Scoring           │      │  student_analyses            │
│  - Recommendations   │      │                              │
│  - 30-Day Plan       │      │  Documents:                  │
│                      │      │  - student_profile           │
│                      │      │  - analysis                  │
│                      │      │  - timestamp                 │
└──────────────────────┘      └──────────────────────────────┘
```

## Component Details

### Frontend (Flutter)

```
frontend/
├── lib/
│   ├── main.dart                    # App entry, Material 3 theme
│   ├── models/
│   │   ├── student_profile.dart     # Input data model
│   │   └── analysis_result.dart     # Analysis result model
│   ├── screens/
│   │   ├── input_screen.dart        # Profile input form
│   │   └── results_screen.dart      # Results display
│   └── services/
│       └── api_service.dart         # HTTP client for backend
└── pubspec.yaml                     # Dependencies
```

**Key Features**:
- Material 3 UI design
- Form validation
- Loading states
- Error handling
- Color-coded readiness levels

### Backend (Flask)

```
backend/
├── app.py                           # Main Flask application
│   ├── Flask app setup
│   ├── Gemini initialization
│   ├── Firebase initialization
│   ├── SYSTEM_PROMPT               # Ethical AI prompt
│   ├── analyze_student_profile()   # AI analysis function
│   ├── save_to_firebase()          # Data storage function
│   ├── POST /analyze               # Main endpoint
│   ├── GET /health                 # Health check
│   └── GET /history/<id>          # History endpoint
├── requirements.txt                # Python dependencies
└── test_api.py                     # Test script
```

**Key Features**:
- RESTful API design
- CORS enabled
- Input validation
- Error handling
- JSON responses

### AI Integration (Gemini)

**System Prompt Structure**:
1. Ethical guidelines
2. Role definition
3. Scoring methodology
4. Output format specification
5. JSON structure requirements

**Output Format**:
```json
{
  "readiness_score": 0-100,
  "readiness_level": "Low|Medium|High",
  "summary": "...",
  "strengths": [...],
  "weak_areas": [...],
  "risk_factors": [...],
  "recommendations": [...],
  "30_day_plan": {
    "week_1": {...},
    "week_2": {...},
    "week_3": {...},
    "week_4": {...}
  }
}
```

### Database (Firebase Firestore)

**Collection**: `student_analyses`

**Document Structure**:
- `student_profile`: Input data
- `analysis`: AI analysis results
- `timestamp`: ISO datetime
- `readiness_score`: For querying
- `readiness_level`: For filtering

## Data Flow

### Analysis Request Flow

```
1. User fills form (Flutter)
   ↓
2. Submit → API Service
   ↓
3. HTTP POST /analyze
   ↓
4. Flask validates input
   ↓
5. Call Gemini API with prompt
   ↓
6. Parse JSON response
   ↓
7. Save to Firebase
   ↓
8. Return JSON to Flutter
   ↓
9. Display results screen
```

### Error Handling Flow

```
API Error
   ↓
Try-Catch in Flask
   ↓
Return error JSON
   ↓
Flutter catches exception
   ↓
Show SnackBar error message
```

## Security Considerations

### Current Implementation
- Input validation on backend
- CORS enabled for development
- Environment variables for secrets
- Firebase Admin SDK (server-side only)

### Production Recommendations
- Add authentication (JWT/OAuth)
- Implement rate limiting
- Add HTTPS
- Secure Firebase rules
- Input sanitization
- API key rotation

## Scalability

### Current Limitations
- Single Flask instance
- No caching
- No load balancing
- Direct Gemini API calls

### Scaling Options
- Use Gunicorn/uWSGI for Flask
- Add Redis caching
- Implement queue system (Celery)
- Use API gateway
- Add CDN for static assets
- Database indexing optimization

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | Flutter | Cross-platform mobile app |
| Backend | Flask | REST API server |
| AI | Gemini API | Analysis and recommendations |
| Database | Firestore | Data persistence |
| Language | Python 3.8+ | Backend development |
| Language | Dart 3.0+ | Frontend development |

## API Contracts

### Request Format
```json
POST /analyze
Content-Type: application/json

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

### Response Format
```json
{
  "success": true,
  "analysis": {
    "readiness_score": 72,
    "readiness_level": "Medium",
    ...
  },
  "document_id": "uuid-here"
}
```

## Deployment Architecture

### Development
```
Local Machine
├── Flutter Dev Server
├── Flask Dev Server (localhost:5000)
├── Gemini API (cloud)
└── Firebase (cloud)
```

### Production (Recommended)
```
┌─────────────┐
│   CDN       │  Static assets
└─────────────┘
       │
┌─────────────┐
│  Load       │  Request routing
│  Balancer   │
└─────────────┘
       │
┌─────────────┐      ┌─────────────┐
│  Flask      │      │  Flask      │  Multiple instances
│  Instance 1 │      │  Instance 2 │
└─────────────┘      └─────────────┘
       │                    │
       └──────────┬─────────┘
                  │
       ┌──────────┴──────────┐
       │                     │
┌─────────────┐      ┌─────────────┐
│  Gemini API │      │  Firebase   │
└─────────────┘      └─────────────┘
```

## Monitoring & Logging

### Recommended Additions
- Application logging (Python logging)
- Error tracking (Sentry)
- Performance monitoring (APM)
- API analytics
- User analytics (Flutter)

---

**Note**: This architecture is designed for hackathon/demo purposes. Production deployment requires additional security, monitoring, and scaling considerations.

