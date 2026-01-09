# Sample Test Data

This document contains sample student profiles for testing the AI Placement Readiness Analyzer.

## Sample Profile 1: High Readiness Student

**Profile Data**:
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

**Expected Characteristics**:
- High readiness score (75-90)
- Readiness level: High
- Strong in most areas
- Minor improvements recommended

---

## Sample Profile 2: Medium Readiness Student

**Profile Data**:
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

**Expected Characteristics**:
- Medium readiness score (50-75)
- Readiness level: Medium
- Good foundation with some gaps
- Focused improvements needed

---

## Sample Profile 3: Low Readiness Student

**Profile Data**:
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

**Expected Characteristics**:
- Low readiness score (0-50)
- Readiness level: Low
- Significant gaps identified
- Comprehensive improvement plan needed

---

## Sample Profile 4: Balanced Medium-High Student

**Profile Data**:
```json
{
  "attendance": 88,
  "cgpa_range": "7-8",
  "dsa_practice": 6,
  "projects": 4,
  "internship": "Short",
  "mock_interview": 78,
  "resume_score": 82
}
```

**Expected Characteristics**:
- Medium-High readiness score (65-80)
- Readiness level: Medium or High
- Well-rounded profile
- Targeted improvements

---

## Sample Profile 5: Strong Technical, Weak Academic

**Profile Data**:
```json
{
  "attendance": 75,
  "cgpa_range": "6-7",
  "dsa_practice": 8,
  "projects": 6,
  "internship": "Long",
  "mock_interview": 80,
  "resume_score": 85
}
```

**Expected Characteristics**:
- Medium readiness score (may vary)
- Strong technical skills
- Academic performance is a concern
- Focus on academic improvement

---

## Sample Profile 6: Strong Academic, Weak Technical

**Profile Data**:
```json
{
  "attendance": 92,
  "cgpa_range": "9-10",
  "dsa_practice": 2,
  "projects": 2,
  "internship": "None",
  "mock_interview": 60,
  "resume_score": 70
}
```

**Expected Characteristics**:
- Medium readiness score (may vary)
- Strong academic performance
- Technical skills need development
- Focus on DSA and projects

---

## Testing Scenarios

### Edge Cases

1. **Perfect Score**:
   ```json
   {
     "attendance": 100,
     "cgpa_range": "9-10",
     "dsa_practice": 10,
     "projects": 10,
     "internship": "Long",
     "mock_interview": 100,
     "resume_score": 100
   }
   ```

2. **Minimum Scores**:
   ```json
   {
     "attendance": 0,
     "cgpa_range": "0-5",
     "dsa_practice": 0,
     "projects": 0,
     "internship": "None",
     "mock_interview": 0,
     "resume_score": 0
   }
   ```

3. **Mixed Performance**:
   ```json
   {
     "attendance": 50,
     "cgpa_range": "7-8",
     "dsa_practice": 5,
     "projects": 0,
     "internship": "Long",
     "mock_interview": 90,
     "resume_score": 50
   }
   ```

## Using Sample Data

### Via API (cURL)

```bash
curl -X POST http://localhost:5000/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "attendance": 85,
    "cgpa_range": "7-8",
    "dsa_practice": 5,
    "projects": 3,
    "internship": "Short",
    "mock_interview": 75,
    "resume_score": 80
  }'
```

### Via Flutter App

1. Open the app
2. Fill in the form with sample data
3. Click "Analyze Readiness"
4. Review the results

## Expected Analysis Output Structure

All analyses should return:

```json
{
  "readiness_score": <0-100>,
  "readiness_level": "<Low|Medium|High>",
  "summary": "<2-3 sentence overview>",
  "strengths": ["<strength1>", "<strength2>", ...],
  "weak_areas": ["<weakness1>", "<weakness2>", ...],
  "risk_factors": ["<risk1>", "<risk2>", ...],
  "recommendations": ["<rec1>", "<rec2>", ...],
  "30_day_plan": {
    "week_1": {
      "focus": "<focus area>",
      "tasks": ["<task1>", "<task2>", "<task3>"]
    },
    "week_2": { ... },
    "week_3": { ... },
    "week_4": { ... }
  }
}
```

## Validation Checklist

When testing, verify:

- ✅ Readiness score is between 0-100
- ✅ Readiness level matches score range:
  - Low: 0-50
  - Medium: 51-75
  - High: 76-100
- ✅ Summary is 2-3 sentences
- ✅ Strengths list has at least 2 items
- ✅ Weak areas list has at least 2 items
- ✅ Risk factors are identified
- ✅ Recommendations are actionable
- ✅ 30-day plan has 4 weeks
- ✅ Each week has a focus and 3 tasks
- ✅ No company names or hiring guarantees mentioned
- ✅ Analysis is constructive and encouraging

