# 🚀 Production Deployment Guide

This guide will help you deploy both the **Flutter frontend** (already on Firebase Hosting) and the **Flask backend** to make your app accessible to everyone.

## 🔴 Current Problem

Your app is deployed on Firebase Hosting, but it's trying to connect to `localhost:5000`, which only works on your local machine. When others access your app, their browsers try to connect to their own `localhost`, causing connection errors.

## ✅ Solution Overview

1. **Deploy Flask backend** to a cloud service (Render, Railway, Heroku, etc.)
2. **Update Flutter app** to use the deployed backend URL
3. **Rebuild and redeploy** the Flutter app to Firebase Hosting

---

## 📋 Step 1: Deploy Flask Backend

Choose one of these free hosting options:

### Option A: Render (Recommended - Free Tier Available)

1. **Create Account**: Go to [render.com](https://render.com) and sign up

2. **Create New Web Service**:
   - Click "New +" → "Web Service"
   - Connect your GitHub repository (or create one)
   - Select the `backend` folder

3. **Configure Service**:
   - **Name**: `skillgap-ai-backend` (or your choice)
   - **Environment**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `gunicorn app:app --bind 0.0.0.0:$PORT`
   - **Plan**: Free (or paid for better performance)

4. **Set Environment Variables**:
   - Go to "Environment" tab
   - Add these variables:
     ```
     GEMINI_API_KEY=your_gemini_api_key_here
     FIREBASE_CREDENTIALS_PATH=/opt/render/project/src/firebase-service-account.json
     FLASK_ENV=production
     PORT=10000
     ```

5. **Upload Firebase Credentials**:
   - In the "Environment" tab, scroll to "Secret Files"
   - Upload your `firebase-service-account.json` file
   - Note the path (usually `/opt/render/project/src/firebase-service-account.json`)

6. **Deploy**:
   - Click "Create Web Service"
   - Wait for deployment (5-10 minutes)
   - Copy your service URL (e.g., `https://skillgap-ai-backend.onrender.com`)

7. **Update Firebase Credentials Path**:
   - After deployment, check the actual path in Render's file system
   - Update `FIREBASE_CREDENTIALS_PATH` environment variable accordingly

### Option B: Railway (Free Trial)

1. **Create Account**: Go to [railway.app](https://railway.app)

2. **New Project**:
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository

3. **Configure**:
   - Select `backend` folder
   - Railway auto-detects Python

4. **Environment Variables**:
   - Go to "Variables" tab
   - Add:
     ```
     GEMINI_API_KEY=your_key
     FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json
     PORT=5000
     ```

5. **Upload Firebase JSON**:
   - Add `firebase-service-account.json` to your `backend/` folder
   - Commit and push to GitHub
   - Railway will auto-deploy

6. **Get URL**: Copy the generated URL (e.g., `https://your-app.railway.app`)

### Option C: Google Cloud Run (Free Tier)

1. **Install gcloud CLI**: [Install Guide](https://cloud.google.com/sdk/docs/install)

2. **Create Dockerfile** in `backend/`:
   ```dockerfile
   FROM python:3.11-slim
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   COPY . .
   CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
   ```

3. **Deploy**:
   ```bash
   cd backend
   gcloud run deploy skillgap-backend \
     --source . \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --set-env-vars GEMINI_API_KEY=your_key
   ```

4. **Get URL**: Copy the service URL from Cloud Console

### Option D: Replit (Quick & Easy)

1. **Create Repl**: Go to [replit.com](https://replit.com)
2. **Import from GitHub**: Your backend folder
3. **Set Secrets**: Add `GEMINI_API_KEY` and Firebase credentials
4. **Run**: Click "Run" button
5. **Get URL**: Copy the Repl URL

---

## 📋 Step 2: Update Flutter App Configuration

After deploying your backend, you need to update the Flutter app to use the new URL.

### Method 1: Hardcode Production URL (Quick Fix)

1. Open `frontend/lib/services/api_service.dart`

2. Find this line (around line 17):
   ```dart
   static const String _productionBackendUrl = ''; // ⬅️ SET YOUR PRODUCTION URL HERE
   ```

3. Replace with your deployed backend URL:
   ```dart
   static const String _productionBackendUrl = 'https://your-backend.onrender.com';
   ```
   ⚠️ **Important**: Make sure the URL starts with `https://` (not `http://`)

### Method 2: Use Build-Time Variable (Recommended)

1. **Build with environment variable**:
   ```bash
   cd frontend
   flutter build web --dart-define=API_BASE_URL=https://your-backend.onrender.com
   ```

2. **Deploy to Firebase**:
   ```bash
   firebase deploy --only hosting
   ```

---

## 📋 Step 3: Update Backend CORS Settings

Make sure your deployed backend allows requests from your Firebase Hosting domain.

1. Open `backend/app.py`

2. Find the CORS configuration (should be around line 25):
   ```python
   CORS(app)
   ```

3. Update it to allow your Firebase domain:
   ```python
   from flask_cors import CORS
   
   CORS(app, resources={
       r"/*": {
           "origins": [
               "https://your-app.web.app",
               "https://your-app.firebaseapp.com",
               "http://localhost:*",  # For local development
           ],
           "methods": ["GET", "POST", "OPTIONS"],
           "allow_headers": ["Content-Type", "Authorization"]
       }
   })
   ```

   Replace `your-app` with your actual Firebase project ID.

4. **Redeploy backend** after this change.

---

## 📋 Step 4: Rebuild and Redeploy Frontend

1. **Build for production**:
   ```bash
   cd frontend
   flutter clean
   flutter pub get
   flutter build web --release
   ```

2. **Deploy to Firebase Hosting**:
   ```bash
   firebase deploy --only hosting
   ```

---

## 🧪 Step 5: Test Your Deployment

1. **Test Backend Health**:
   - Open: `https://your-backend.onrender.com/health`
   - Should return: `{"status": "healthy", ...}`

2. **Test Frontend**:
   - Open your Firebase Hosting URL
   - Try to sign in and create an assessment
   - Check browser console for errors

3. **Common Issues**:
   - **CORS errors**: Update CORS settings in backend
   - **Connection refused**: Backend URL not set correctly
   - **500 errors**: Check backend logs for API key/Firebase issues

---

## 🔧 Additional Backend Configuration

### Add Gunicorn for Production

If using Render/Railway, create `backend/requirements.txt` and ensure it includes:
```
gunicorn==21.2.0
```

### Update Backend for Production

Your `backend/app.py` should handle production port:

```python
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
```

For production, use Gunicorn:
```bash
gunicorn app:app --bind 0.0.0.0:$PORT --workers 2
```

---

## 📝 Quick Checklist

- [ ] Backend deployed to cloud service
- [ ] Backend URL copied (e.g., `https://xxx.onrender.com`)
- [ ] Updated `_productionBackendUrl` in `api_service.dart`
- [ ] Updated CORS settings in `backend/app.py`
- [ ] Rebuilt Flutter app: `flutter build web`
- [ ] Redeployed to Firebase: `firebase deploy`
- [ ] Tested health endpoint
- [ ] Tested full flow (sign in → assessment → results)

---

## 🆘 Troubleshooting

### Error: "Failed to fetch" or "Connection refused"

- **Check**: Backend URL is correct in `api_service.dart`
- **Check**: Backend is actually running (test `/health` endpoint)
- **Check**: URL uses `https://` not `http://`

### Error: CORS policy blocked

- **Check**: CORS settings in `backend/app.py` include your Firebase domain
- **Check**: Backend allows your origin

### Error: 500 Internal Server Error

- **Check**: Backend logs (Render/Railway dashboard)
- **Check**: `GEMINI_API_KEY` is set correctly
- **Check**: Firebase credentials path is correct

### Backend goes to sleep (Render free tier)

- **Solution**: Use a service like [UptimeRobot](https://uptimerobot.com) to ping your backend every 5 minutes
- **Or**: Upgrade to paid plan

---

## 💡 Pro Tips

1. **Use Environment Variables**: Don't hardcode API keys
2. **Monitor Logs**: Check backend logs regularly
3. **Set Up Alerts**: Get notified of errors
4. **Use HTTPS**: Always use `https://` in production
5. **Test Locally First**: Test with production URL locally before deploying

---

## 📚 Additional Resources

- [Render Documentation](https://render.com/docs)
- [Railway Documentation](https://docs.railway.app)
- [Firebase Hosting Guide](https://firebase.google.com/docs/hosting)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

---

**Need Help?** Check the backend logs in your hosting provider's dashboard for detailed error messages.
