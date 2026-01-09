"""
Simple test script for the Flask API
Run this after starting the backend server to verify everything works
"""

import requests
import json

BASE_URL = "http://localhost:5000"

def test_health():
    """Test health endpoint"""
    print("Testing /health endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        print(f"Status: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except Exception as e:
        print(f"Error: {e}")
        return False

def test_analyze():
    """Test analyze endpoint with sample data"""
    print("\nTesting /analyze endpoint...")
    
    sample_data = {
        "attendance": 85,
        "cgpa_range": "7-8",
        "dsa_practice": 5,
        "projects": 3,
        "internship": "Short",
        "mock_interview": 75,
        "resume_score": 80
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/analyze",
            json=sample_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Success: {data.get('success')}")
            if 'analysis' in data:
                analysis = data['analysis']
                print(f"\nReadiness Score: {analysis.get('readiness_score')}")
                print(f"Readiness Level: {analysis.get('readiness_level')}")
                print(f"Summary: {analysis.get('summary', '')[:100]}...")
                print(f"\nDocument ID: {data.get('document_id')}")
            return True
        else:
            print(f"Error: {response.text}")
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    print("=" * 50)
    print("API Test Script")
    print("=" * 50)
    
    # Test health endpoint
    health_ok = test_health()
    
    if health_ok:
        # Test analyze endpoint
        analyze_ok = test_analyze()
        
        if analyze_ok:
            print("\n" + "=" * 50)
            print("✅ All tests passed!")
            print("=" * 50)
        else:
            print("\n" + "=" * 50)
            print("❌ Analyze test failed")
            print("=" * 50)
    else:
        print("\n" + "=" * 50)
        print("❌ Health check failed. Is the server running?")
        print("=" * 50)
        print("Start the server with: python app.py")

