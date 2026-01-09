# 🚨 Quick Fix: Production Backend URL

## The Problem
Your app is deployed on Firebase Hosting but trying to connect to `localhost:5000`, which doesn't work for other users.

## ⚡ Quick Solution (5 minutes)

### Step 1: Deploy Your Backend (Choose One)

#### Option A: Render (Easiest - Free)
1. Go to [render.com](https://render.com) → Sign up
2. Click "New +" → "Web Service"
3. Connect your GitHub repo (or upload `backend/` folder)
4. Settings:
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn app:app --bind 0.0.0.0:$PORT`
5. Environment Variables:
   - `GEMINI_API_KEY` = your Gemini API key
   - `FIREBASE_CREDENTIALS_PATH` = path to your Firebase JSON (upload it as a secret file)
   - `PORT` = `10000`
6. Click "Create Web Service"
7. **Copy the URL** (e.g., `https://skillgap-ai-backend.onrender.com`)

#### Option B: Replit (Fastest)
1. Go to [replit.com](https://replit.com) → Create Repl
2. Import your `backend/` folder
3. Add secrets: `GEMINI_API_KEY` and Firebase credentials
4. Click "Run"
5. **Copy the Repl URL**

### Step 2: Update Flutter App

1. Open `frontend/lib/services/api_service.dart`

2. Find line ~17:
   ```dart
   static const String _productionBackendUrl = ''; // ⬅️ SET YOUR PRODUCTION URL HERE
   ```

3. Replace with your backend URL:
   ```dart
   static const String _productionBackendUrl = 'https://your-backend.onrender.com';
   ```
   ⚠️ **Must use `https://` not `http://`**

### Step 3: Rebuild and Deploy

```bash
cd frontend
flutter clean
flutter pub get
flutter build web --release
firebase deploy --only hosting
```

### Step 4: Test

1. Open your Firebase Hosting URL
2. Try signing in and creating an assessment
3. Check browser console (F12) for errors

---

## ✅ Done!

Your app should now work for everyone!

---

## 🆘 Still Not Working?

### Check Backend Health
Open: `https://your-backend-url.com/health`

Should return:
```json
{"status": "healthy", "gemini_configured": true, "firebase_configured": true}
```

### Common Issues

1. **CORS Error**: 
   - Backend `app.py` already allows all origins
   - If still failing, check backend logs

2. **Connection Refused**:
   - Verify URL in `api_service.dart` is correct
   - Make sure it starts with `https://`

3. **500 Error**:
   - Check backend logs
   - Verify `GEMINI_API_KEY` is set
   - Verify Firebase credentials are uploaded

---

## 📝 Example URLs

- Render: `https://skillgap-backend.onrender.com`
- Railway: `https://skillgap-backend.railway.app`
- Replit: `https://skillgap-backend.repl.co`
- Heroku: `https://skillgap-backend.herokuapp.com`

Make sure to replace with YOUR actual backend URL!
