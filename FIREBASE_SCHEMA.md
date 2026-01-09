# Firebase Firestore Data Schema

## Collection: `student_analyses`

Stores student profile data and AI analysis results.

### Document Structure

Each document represents a single analysis session.

#### Document ID
- Type: `string` (UUID)
- Format: Generated UUID v4

#### Document Fields

```typescript
{
  // Student profile data
  student_profile: {
    attendance: number,        // 0-100
    cgpa_range: string,        // "0-5" | "5-6" | "6-7" | "7-8" | "8-9" | "9-10"
    dsa_practice: number,      // Non-negative integer (times per week)
    projects: number,          // Non-negative integer
    internship: string,        // "None" | "Short" | "Long"
    mock_interview: number,    // 0-100
    resume_score: number       // 0-100
  },

  // AI analysis results
  analysis: {
    readiness_score: number,           // 0-100
    readiness_level: string,           // "Low" | "Medium" | "High"
    summary: string,                   // 2-3 sentence overview
    strengths: string[],               // Array of strength descriptions
    weak_areas: string[],              // Array of weakness descriptions
    risk_factors: string[],            // Array of risk factor descriptions
    recommendations: string[],         // Array of recommendation descriptions
    "30_day_plan": {                   // Note: Key uses quotes due to number prefix
      week_1: {
        focus: string,                 // Main focus area for the week
        tasks: string[]                // Array of specific tasks
      },
      week_2: {
        focus: string,
        tasks: string[]
      },
      week_3: {
        focus: string,
        tasks: string[]
      },
      week_4: {
        focus: string,
        tasks: string[]
      }
    }
  },

  // Metadata
  timestamp: string,           // ISO 8601 format datetime
  readiness_score: number,     // Duplicate for easy querying (0-100)
  readiness_level: string     // Duplicate for easy querying ("Low" | "Medium" | "High")
}
```

### Example Document

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
    "summary": "You have a solid foundation with good academic performance and consistent DSA practice. Your internship experience adds value, but there's room for improvement in technical projects and interview preparation.",
    "strengths": [
      "Strong attendance record (85%)",
      "Consistent DSA practice (5 times/week)",
      "Good academic performance (CGPA 7-8)"
    ],
    "weak_areas": [
      "Limited technical projects (only 3)",
      "Mock interview score could be higher",
      "Resume needs more refinement"
    ],
    "risk_factors": [
      "Limited project portfolio may not showcase practical skills",
      "Interview performance needs improvement"
    ],
    "recommendations": [
      "Build 2-3 more technical projects focusing on different domains",
      "Practice mock interviews weekly",
      "Enhance resume with quantifiable achievements"
    ],
    "30_day_plan": {
      "week_1": {
        "focus": "Project Development",
        "tasks": [
          "Start a new full-stack project",
          "Set up GitHub repository",
          "Complete project planning and design"
        ]
      },
      "week_2": {
        "focus": "DSA & Problem Solving",
        "tasks": [
          "Solve 20 medium-level problems",
          "Focus on arrays and strings",
          "Participate in coding contests"
        ]
      },
      "week_3": {
        "focus": "Interview Preparation",
        "tasks": [
          "Take 3 mock interviews",
          "Practice system design concepts",
          "Review common interview questions"
        ]
      },
      "week_4": {
        "focus": "Resume & Portfolio",
        "tasks": [
          "Update resume with new projects",
          "Create portfolio website",
          "Get feedback from mentors"
        ]
      }
    }
  },
  "timestamp": "2024-01-15T10:30:00.123456",
  "readiness_score": 72,
  "readiness_level": "Medium"
}
```

## Querying Examples

### Get all analyses sorted by timestamp (descending)
```python
analyses_ref = db.collection('student_analyses')
docs = analyses_ref.order_by('timestamp', direction=firestore.Query.DESCENDING).stream()
```

### Get analyses by readiness level
```python
docs = db.collection('student_analyses').where('readiness_level', '==', 'High').stream()
```

### Get analyses with score above threshold
```python
docs = db.collection('student_analyses').where('readiness_score', '>=', 75).stream()
```

### Get recent analyses (last 10)
```python
docs = db.collection('student_analyses')\
    .order_by('timestamp', direction=firestore.Query.DESCENDING)\
    .limit(10)\
    .stream()
```

## Indexes Required

Firestore requires composite indexes for certain queries. Create these in Firebase Console:

1. **Collection**: `student_analyses`
   - Fields: `timestamp` (Descending)
   - Purpose: Sorting by timestamp

2. **Collection**: `student_analyses`
   - Fields: `readiness_level` (Ascending), `timestamp` (Descending)
   - Purpose: Filtering by level and sorting by time

3. **Collection**: `student_analyses`
   - Fields: `readiness_score` (Descending), `timestamp` (Descending)
   - Purpose: Filtering by score and sorting by time

## Security Rules (Example)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /student_analyses/{documentId} {
      // Allow read access to all (adjust based on your auth requirements)
      allow read: if true;
      
      // Only allow writes from authenticated backend
      allow write: if false; // Backend writes only via Admin SDK
    }
  }
}
```

**Note**: In production, implement proper authentication and authorization rules.

## Future Enhancements

Consider adding:
- User authentication (link analyses to user accounts)
- Student ID field for tracking individual progress
- Tags/categories for better organization
- Analysis version field for tracking prompt changes
- Feedback/rating system

