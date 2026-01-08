import os
import google.generativeai as genai

# Make sure your .env is loaded or set GEMINI_API_KEY
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    print("GEMINI_API_KEY not set")
    exit(1)

genai.configure(api_key=GEMINI_API_KEY)

# List all available models
models = genai.list_models()
for m in models:
    print(m)
