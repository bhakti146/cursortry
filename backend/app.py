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

# Load environment variables
# Try to load from current directory first, then try absolute path for local development
env_path = os.path.join(os.path.dirname(__file__), '.env')
if os.path.exists(env_path):
    load_dotenv(env_path, override=True)
else:
    # Fallback for local development with absolute path
    local_env_path = os.path.join(os.path.dirname(__file__), '..', 'backend', '.env')
    if os.path.exists(local_env_path):
        load_dotenv(local_env_path, override=True)
    else:
        # In production, environment variables are usually set directly
        load_dotenv(override=True)

app = Flask(__name__)

# Configure CORS for production
# Allow requests from Firebase Hosting domains and localhost for development
allowed_origins = [
    "http://localhost:*",
    "http://127.0.0.1:*",
]

# Add Firebase Hosting domains if provided via environment variable
firebase_domain = os.getenv('FIREBASE_HOSTING_DOMAIN', '')
if firebase_domain:
    allowed_origins.extend([
        f"https://{firebase_domain}",
        f"https://{firebase_domain.replace('.web.app', '.firebaseapp.com')}",
    ])

# For production, allow all origins (you can restrict this later)
# In production, you should set specific domains
CORS(app, resources={
    r"/*": {
        "origins": "*",  # In production, replace with specific domains
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

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
- DSA Practice Frequency: 15% weight (critical for technical interviews - Daily > Weekly > Monthly)
- Internship Experience: 12% weight (real-world experience - longer duration and company relevance)
- Mock Interview Score (0-10): 12% weight (interview readiness and communication)
- Resume Completeness (0-100): 10% weight (presentation and documentation quality)
- Hackathons: 8% weight (competitive programming, problem-solving, and innovation)
- Technologies/Languages: 8% weight (technical skills and programming expertise)
- Certifications: 10% weight (professional credentials and specialized expertise)
- Projects: 8% weight (practical application, problem-solving, and portfolio development)

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
- College Tier: {student_data.get('college_tier', 'N/A')}
- Qualification: {student_data.get('qualification', 'N/A')}
- Department: {student_data.get('department', 'N/A')}

Academic Performance:
- CGPA: {student_data.get('cgpa', 0)}/10
- Attendance: {student_data.get('attendance', 0)}%

Achievements:
- Hackathons: {student_data.get('hackathons', 'None')}
- Mastered Languages/Technologies: {student_data.get('technologies', 'None')}
- Certifications: {student_data.get('certifications', 'None')}
- Projects: {student_data.get('projects', 'None')}

Skills & Experience:
- DSA Practice Frequency: {student_data.get('dsa_practice_frequency', 'N/A')}
- Internships: {len(student_data.get('internships', []))} internship(s)
{chr(10).join([f"  - {internship.get('company', 'N/A')} ({internship.get('duration', 'N/A')})" for internship in student_data.get('internships', [])]) if student_data.get('internships') else "  - None"}
- Mock Interview Score: {student_data.get('mock_interview_score', 0)}/10
- Resume Completeness: {student_data.get('resume_score', 0)}/100

Provide your analysis following the JSON format specified in the system prompt."""

    # Check if model is available
    if model is None:
        raise Exception("Gemini API is not configured. Please check your API key.")
    
    try:
        # Combine system prompt with user prompt
        full_prompt = f"{SYSTEM_PROMPT}\n\n{prompt}"
        
        response = model.generate_content(full_prompt)
        
        # Check if response is valid
        if not response or not hasattr(response, 'text') or not response.text:
            raise Exception("Empty response from Gemini API")
        
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
        error_str = str(e)
        # Handle quota exceeded errors specifically
        if "429" in error_str or "quota" in error_str.lower() or "exceeded" in error_str.lower():
            # Extract retry time if available
            if "retry" in error_str.lower() or "seconds" in error_str.lower():
                raise Exception("API quota exceeded. You've reached the daily limit. Please try again tomorrow or upgrade your API plan.")
            else:
                raise Exception("API quota exceeded. You've reached the daily limit (20 requests/day on free tier). Please try again tomorrow or upgrade your API plan.")
        # Handle rate limit errors
        elif "rate limit" in error_str.lower():
            raise Exception("API rate limit exceeded. Please wait a moment and try again.")
        # Handle API key errors
        elif "api key" in error_str.lower() or "401" in error_str or "403" in error_str:
            raise Exception("Invalid or missing Gemini API key. Please check your API configuration.")
        # Generic error
        else:
            raise Exception(f"Gemini API error: {error_str}")

def save_to_firebase(student_data, analysis_result):
    """
    Save student profile and analysis to Firebase Firestore
    """
    if not db:
        return None
    
    try:
        # Create document with unique ID
        doc_id = str(uuid.uuid4())
        
        # Get user_id from request data
        user_id = student_data.get('user_id', '')
        
        # Prepare document data
        document_data = {
            'user_id': user_id,  # Link to user account
            'student_profile': {
                'name': student_data.get('name', ''),
                'location': student_data.get('location', ''),
                'college': student_data.get('college', ''),
                'college_tier': student_data.get('college_tier', ''),
                'qualification': student_data.get('qualification', ''),
                'department': student_data.get('department', ''),
                'cgpa': student_data.get('cgpa', 0),
                'attendance': student_data.get('attendance', 0),
                'hackathons': student_data.get('hackathons', ''),
                'technologies': student_data.get('technologies', ''),
                'certifications': student_data.get('certifications', ''),
                'projects': student_data.get('projects', ''),
                'dsa_practice_frequency': student_data.get('dsa_practice_frequency', 'N/A'),
                'internships': student_data.get('internships', []),
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
        required_fields = ['name', 'location', 'college', 'college_tier', 'qualification', 'department', 'cgpa', 
                          'attendance', 'hackathons', 'technologies', 'certifications', 'projects',
                          'dsa_practice_frequency', 'internships', 
                          'mock_interview_score', 'resume_score']
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
        # Validate DSA frequency
        valid_dsa_frequencies = ['Daily', 'Weekly', 'Monthly']
        if 'dsa_practice_frequency' in data and data.get('dsa_practice_frequency') not in valid_dsa_frequencies:
            return jsonify({'error': 'DSA practice frequency must be Daily, Weekly, or Monthly'}), 400
        
        # Validate internships
        if 'internships' in data:
            internships = data.get('internships', [])
            if not isinstance(internships, list):
                return jsonify({'error': 'Internships must be a list'}), 400
            valid_durations = ['1 month', '3 months', '6 months', '1 year']
            for internship in internships:
                if not isinstance(internship, dict):
                    return jsonify({'error': 'Each internship must be an object with company and duration'}), 400
                if 'duration' in internship and internship.get('duration') not in valid_durations:
                    return jsonify({'error': 'Internship duration must be 1 month, 3 months, 6 months, or 1 year'}), 400
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
        error_message = str(e)
        # Determine appropriate HTTP status code
        status_code = 500
        if "quota" in error_message.lower() or "exceeded" in error_message.lower():
            status_code = 429  # Too Many Requests
        elif "not configured" in error_message.lower() or "api key" in error_message.lower():
            status_code = 503  # Service Unavailable
        elif "Missing required" in error_message or "must be between" in error_message:
            status_code = 400  # Bad Request
        
        print(f"Error in /analyze endpoint: {error_message}")
        return jsonify({
            'error': error_message,
            'success': False
        }), status_code

@app.route('/user/<user_id>/analyses', methods=['GET'])
def get_user_analyses(user_id):
    """
    Retrieve analysis history for a specific user
    """
    if not db:
        return jsonify({'error': 'Firebase not configured'}), 503
    
    try:
        # Query Firestore for user's analyses
        analyses_ref = db.collection('student_analyses')
        
        # Try with order_by, fallback to without if index is missing
        try:
            docs = analyses_ref.where('user_id', '==', user_id)\
                              .order_by('timestamp', direction=firestore.Query.DESCENDING)\
                              .limit(50)\
                              .stream()
        except Exception as order_error:
            print(f"Warning: Could not order by timestamp, fetching without order: {order_error}")
            # Fallback: fetch without ordering
            docs = analyses_ref.where('user_id', '==', user_id)\
                              .limit(50)\
                              .stream()
        
        analyses = []
        for doc in docs:
            try:
                doc_data = doc.to_dict()
                
                # Handle timestamp conversion
                timestamp = doc_data.get('timestamp')
                if timestamp is None:
                    timestamp_str = datetime.now().isoformat()
                elif isinstance(timestamp, str):
                    timestamp_str = timestamp
                elif hasattr(timestamp, 'isoformat'):
                    timestamp_str = timestamp.isoformat()
                else:
                    timestamp_str = str(timestamp)
                
                # Ensure readiness_score is a number (convert to int if float)
                readiness_score = doc_data.get('readiness_score', 0)
                if isinstance(readiness_score, float):
                    readiness_score = int(readiness_score)
                
                analyses.append({
                    'id': doc.id,
                    'timestamp': timestamp_str,
                    'readiness_score': readiness_score,
                    'readiness_level': doc_data.get('readiness_level', 'Low'),
                    'analysis': doc_data.get('analysis'),  # Include full analysis
                    'student_profile': doc_data.get('student_profile', {})
                })
            except Exception as doc_error:
                print(f"Error processing document {doc.id}: {doc_error}")
                continue
        
        # Sort in Python if order_by failed
        if len(analyses) > 1:
            try:
                analyses.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
            except:
                pass
        
        return jsonify({
            'success': True,
            'analyses': analyses
        }), 200
    
    except Exception as e:
        print(f"Error fetching user analyses: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': str(e),
            'success': False
        }), 500

if __name__ == '__main__':
    # For local development
    port = int(os.getenv('FLASK_PORT', 5000))
    debug_mode = os.getenv('FLASK_ENV', 'development') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug_mode)
else:
    # For production with Gunicorn
    # Gunicorn will handle the server
    pass


