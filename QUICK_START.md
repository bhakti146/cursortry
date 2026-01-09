# Quick Start Guide

## 🚀 Starting the Application

### Step 1: Start the Backend Server

1. **Open a terminal/command prompt**

2. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

3. **Activate your Python virtual environment** (if you have one):
   ```bash
   # Windows
   venv\Scripts\activate
   
   # Mac/Linux
   source venv/bin/activate
   ```

4. **Start the Flask server:**
   ```bash
   python app.py
   ```

   You should see output like:
   ```
   Firebase initialized successfully
   * Running on http://0.0.0.0:5000
   ```

   **⚠️ Keep this terminal window open!** The server must be running for the app to work.

### Step 2: Start the Frontend

1. **Open a NEW terminal/command prompt** (keep the backend terminal running)

2. **Navigate to the frontend directory:**
   ```bash
   cd frontend
   ```

3. **Run the Flutter app:**
   ```bash
   flutter run
   ```

   Or for web:
   ```bash
   flutter run -d chrome
   ```

### Step 3: Test the Connection

1. The app should now be able to connect to the backend
2. Fill out the assessment form
3. Click "Start AI Analysis"
4. You should see the analysis results

## 🔧 Troubleshooting

### Error: `ERR_CONNECTION_REFUSED`

**Problem:** Backend server is not running

**Solution:**
1. Make sure you started the backend server (Step 1)
2. Check that the backend terminal shows "Running on http://0.0.0.0:5000"
3. Verify the backend is accessible by opening: http://localhost:5000/health in your browser
   - You should see: `{"status":"healthy",...}`

### Error: `ModuleNotFoundError` or `No module named 'flask'`

**Problem:** Python dependencies not installed

**Solution:**
```bash
cd backend
pip install -r requirements.txt
```

### Error: `GEMINI_API_KEY not set`

**Problem:** Missing API key in `.env` file

**Solution:**
1. Check that `backend/.env` file exists
2. Verify it contains: `GEMINI_API_KEY=your_key_here`
3. Get your API key from: https://makersuite.google.com/app/apikey

### Error: `Firebase credentials not found`

**Problem:** Firebase service account JSON file missing

**Solution:**
1. Check that `FIREBASE_CREDENTIALS_PATH` in `.env` points to a valid JSON file
2. Download the service account JSON from Firebase Console

### For Physical Devices

If you're testing on a physical Android/iOS device:

1. **Find your computer's IP address:**
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`

2. **Update `frontend/lib/services/api_service.dart`:**
   ```dart
   static const String baseUrl = 'http://YOUR_IP_ADDRESS:5000';
   // Example: 'http://192.168.1.100:5000'
   ```

3. **Make sure your phone and computer are on the same WiFi network**

## 📝 Important Notes

- **Always start the backend first** before running the frontend
- The backend terminal must stay open while using the app
- For web development, `localhost:5000` works fine
- For Android emulator, the code automatically uses `10.0.2.2:5000`
- For iOS simulator, `localhost:5000` works fine

## ✅ Verification Checklist

Before testing the app, make sure:

- [ ] Backend server is running (terminal shows "Running on...")
- [ ] Backend health check works: http://localhost:5000/health
- [ ] `.env` file exists in `backend/` directory
- [ ] `GEMINI_API_KEY` is set in `.env`
- [ ] Firebase credentials path is correct in `.env`
- [ ] Frontend dependencies installed (`flutter pub get`)
- [ ] Both terminals are open (backend + frontend)
