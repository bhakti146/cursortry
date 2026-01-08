"""
AI Placement Readiness & Skill Gap Analyzer - Flask Backend
Main API server for handling analysis requests
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
import firebase_admin
from firebase_admin import credentials, firestore
import os
from dotenv import load_dotenv
import json
from datetime import datetime
import uuid

print(os.path.exists("F:/techcatalyst/cursortry/backend/.env"))


# Load environment variables
load_dotenv("F:/techcatalyst/cursortry/backend/.env", override=True)
print("GEMINI_API_KEY from os.environ:", os.environ.get("APIKEY"))

app = Flask(__name__)
CORS(app)

# Initialize Gemini AI
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
print("ENV GEMINI_API_KEY:", os.getenv("GEMINI_API_KEY"))



if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-2.5-flash')
else:
    model = None
    print("Warning: GEMINI_API_KEY not set")

# Initialize Firebase
try:
    cred_path = os.getenv('FIREBASE_CREDENTIALS_PATH')
    if cred_path and os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Firebase initialized successfully")
    else:
        db = None
        print("Warning: Firebase credentials not found. Data storage disabled.")
except Exception as e:
    db = None
    print(f"Warning: Firebase initialization failed: {e}")

# Gemini System Prompt
SYSTEM_PROMPT = """You are an ethical AI Placement Readiness Analyzer designed to help students evaluate their preparation and identify skill gaps.

CRITICAL ETHICAL GUIDELINES:
- NEVER predict placement outcomes or hiring guarantees
- NEVER mention specific companies or recruiters
- Focus on skill development and improvement
- Provide transparent, explainable reasoning
- Emphasize continuous learning and growth

Your role is to:
1. Analyze student profile data objectively
2. Calculate a Placement Readiness Score (0-100) based on multiple factors
3. Identify strengths and areas for improvement
4. Provide actionable recommendations
5. Create a personalized 30-day improvement plan

SCORING METHODOLOGY:
- CGPA (0-10 scale): 12% weight (academic performance indicator)
- Attendance (0-100%): 8% weight (consistency and discipline)
- Qualification: 5% weight (degree level and relevance)
- DSA Practice Per Week: 15% weight (critical for technical interviews)
- Internship Count: 12% weight (real-world experience and exposure)
- Mock Interview Score (0-10): 12% weight (interview readiness and communication)
- Resume Completeness (0-100): 10% weight (presentation and documentation quality)
- Hackathons: 8% weight (competitive programming, problem-solving, and innovation)
- Technologies/Languages: 8% weight (technical skills and programming expertise)
- Certifications: 10% weight (professional credentials and specialized expertise)

READINESS LEVELS:
- Low (0-50): Significant gaps identified, needs focused improvement
- Medium (51-75): Good foundation, some areas need strengthening
- High (76-100): Well-prepared, minor refinements recommended

OUTPUT FORMAT:
You MUST respond with valid JSON only, no additional text. Use this exact structure:

{
  "readiness_score": <number 0-100>,
  "readiness_level": "<Low|Medium|High>",
  "summary": "<2-3 sentence overview>",
  "strengths": ["<strength1>", "<strength2>", ...],
  "weak_areas": ["<weakness1>", "<weakness2>", ...],
  "risk_factors": ["<risk1>", "<risk2>", ...],
  "recommendations": ["<recommendation1>", "<recommendation2>", ...],
  "30_day_plan": {
    "week_1": {
      "focus": "<main focus area>",
      "tasks": ["<task1>", "<task2>", "<task3>"]
    },
    "week_2": {
      "focus": "<main focus area>",
      "tasks": ["<task1>", "<task2>", "<task3>"]
    },
    "week_3": {
      "focus": "<main focus area>",
      "tasks": ["<task1>", "<task2>", "<task3>"]
    },
    "week_4": {
      "focus": "<main focus area>",
      "tasks": ["<task1>", "<task2>", "<task3>"]
    }
  }
}

Remember: Be encouraging, constructive, and focus on growth opportunities."""

def analyze_student_profile(student_data):
    """
    Analyze student profile using Gemini AI
    Returns structured analysis results
    """
    if not model:
        raise Exception("Gemini API not configured")
    
    # Format student data for prompt
    prompt = f"""Analyze the following student profile:

Personal Information:
- Name: {student_data.get('name', 'N/A')}
- Location: {student_data.get('location', 'N/A')}
- College: {student_data.get('college', 'N/A')}
- Qualification: {student_data.get('qualification', 'N/A')}
- Department: {student_data.get('department', 'N/A')}

Academic Performance:
- CGPA: {student_data.get('cgpa', 0)}/10
- Attendance: {student_data.get('attendance', 0)}%

Achievements:
- Hackathons: {student_data.get('hackathons', 'None')}
- Mastered Languages/Technologies: {student_data.get('technologies', 'None')}
- Certifications: {student_data.get('certifications', 'None')}

Skills & Experience:
- DSA Practice Per Week: {student_data.get('dsa_practice', 0)} hours/problems
- Internship Count: {student_data.get('internship_count', 0)}
- Mock Interview Score: {student_data.get('mock_interview_score', 0)}/10
- Resume Completeness: {student_data.get('resume_score', 0)}/100

Provide your analysis following the JSON format specified in the system prompt."""

    try:
        # Combine system prompt with user prompt
        full_prompt = f"{SYSTEM_PROMPT}\n\n{prompt}"
        
        response = model.generate_content(full_prompt)
        
        # Extract JSON from response
        response_text = response.text.strip()
        
        # Try to extract JSON if wrapped in markdown code blocks
        if "```json" in response_text:
            response_text = response_text.split("```json")[1].split("```")[0].strip()
        elif "```" in response_text:
            response_text = response_text.split("```")[1].split("```")[0].strip()
        
        # Parse JSON
        analysis_result = json.loads(response_text)
        
        # Validate required fields
        required_fields = ['readiness_score', 'readiness_level', 'summary', 'strengths', 
                          'weak_areas', 'risk_factors', 'recommendations', '30_day_plan']
        for field in required_fields:
            if field not in analysis_result:
                raise ValueError(f"Missing required field: {field}")
        
        return analysis_result
    
    except json.JSONDecodeError as e:
        raise Exception(f"Failed to parse Gemini response as JSON: {e}")
    except Exception as e:
        raise Exception(f"Gemini API error: {e}")

def save_to_firebase(student_data, analysis_result):
    """
    Save student profile and analysis to Firebase Firestore
    """
    if not db:
        return None
    
    try:
        # Create document with unique ID
        doc_id = str(uuid.uuid4())
        
        # Prepare document data
        document_data = {
            'student_profile': {
                'name': student_data.get('name', ''),
                'location': student_data.get('location', ''),
                'college': student_data.get('college', ''),
                'qualification': student_data.get('qualification', ''),
                'cgpa': student_data.get('cgpa', 0),
                'attendance': student_data.get('attendance', 0),
                'hackathons': student_data.get('hackathons', ''),
                'courses': student_data.get('courses', ''),
                'certifications': student_data.get('certifications', ''),
                'dsa_practice': student_data.get('dsa_practice', 0),
                'internship_count': student_data.get('internship_count', 0),
                'mock_interview_score': student_data.get('mock_interview_score', 0),
                'resume_score': student_data.get('resume_score', 0)
            },
            'analysis': analysis_result,
            'timestamp': datetime.now().isoformat(),
            'readiness_score': analysis_result['readiness_score'],
            'readiness_level': analysis_result['readiness_level']
        }
        
        # Save to Firestore
        doc_ref = db.collection('student_analyses').document(doc_id)
        doc_ref.set(document_data)
        
        return doc_id
    
    except Exception as e:
        print(f"Firebase save error: {e}")
        return None

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'gemini_configured': model is not None,
        'firebase_configured': db is not None
    })

@app.route('/analyze', methods=['POST'])
def analyze():
    """
    Main analysis endpoint
    Accepts student profile data and returns AI analysis
    """
    try:
        # Validate request
        if not request.is_json:
            return jsonify({'error': 'Request must be JSON'}), 400
        
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['name', 'location', 'college', 'qualification', 'department', 'cgpa', 
                          'attendance', 'hackathons', 'technologies', 'certifications',
                          'dsa_practice', 'internship_count', 'mock_interview_score', 'resume_score']
        missing_fields = [field for field in required_fields if field not in data]
        if missing_fields:
            return jsonify({
                'error': f'Missing required fields: {", ".join(missing_fields)}'
            }), 400
        
        # Validate data ranges
        if data.get('attendance', 0) < 0 or data.get('attendance', 0) > 100:
            return jsonify({'error': 'Attendance must be between 0 and 100'}), 400
        if data.get('cgpa', 0) < 0 or data.get('cgpa', 0) > 10:
            return jsonify({'error': 'CGPA must be between 0 and 10'}), 400
        if data.get('dsa_practice', 0) < 0:
            return jsonify({'error': 'DSA practice must be non-negative'}), 400
        if data.get('internship_count', 0) < 0:
            return jsonify({'error': 'Internship count must be non-negative'}), 400
        if data.get('mock_interview_score', 0) < 0 or data.get('mock_interview_score', 0) > 10:
            return jsonify({'error': 'Mock interview score must be between 0 and 10'}), 400
        if data.get('resume_score', 0) < 0 or data.get('resume_score', 0) > 100:
            return jsonify({'error': 'Resume score must be between 0 and 100'}), 400
        
        # Perform analysis
        analysis_result = analyze_student_profile(data)
        
        # Save to Firebase
        doc_id = save_to_firebase(data, analysis_result)
        
        # Return response
        response = {
            'success': True,
            'analysis': analysis_result,
            'document_id': doc_id
        }
        
        return jsonify(response), 200
    
    except Exception as e:
        return jsonify({
            'error': str(e),
            'success': False
        }), 500

@app.route('/history/<student_id>', methods=['GET'])
def get_history(student_id):
    """
    Retrieve analysis history for a student
    Note: In production, implement proper authentication
    """
    if not db:
        return jsonify({'error': 'Firebase not configured'}), 503
    
    try:
        # Query Firestore for student analyses
        # Note: This is a simplified version. In production, use proper student_id tracking
        analyses_ref = db.collection('student_analyses')
        docs = analyses_ref.order_by('timestamp', direction=firestore.Query.DESCENDING).limit(10).stream()
        
        history = []
        for doc in docs:
            doc_data = doc.to_dict()
            history.append({
                'id': doc.id,
                'timestamp': doc_data.get('timestamp'),
                'readiness_score': doc_data.get('readiness_score'),
                'readiness_level': doc_data.get('readiness_level')
            })
        
        return jsonify({
            'success': True,
            'history': history
        }), 200
    
    except Exception as e:
        return jsonify({
            'error': str(e),
            'success': False
        }), 500

if __name__ == '__main__':
    port = int(os.getenv('FLASK_PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)


