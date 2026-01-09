# Quick Start - Get the App Running

## Step 1: Install Dependencies

```bash
cd frontend
flutter pub get
```

## Step 2: Verify Firebase Configuration

Make sure `lib/firebase_options.dart` exists. If not:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (will generate firebase_options.dart)
flutterfire configure
```

## Step 3: Run the App

### Option A: Run on Connected Device/Emulator
```bash
flutter run
```

### Option B: Run on Specific Platform
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web (if configured)
flutter run -d chrome

# Windows
flutter run -d windows
```

## Step 4: If You Get Errors

### Error: "Firebase not initialized"
- Check `lib/firebase_options.dart` exists
- Verify Firebase project is set up in Firebase Console

### Error: "Package not found"
```bash
flutter clean
flutter pub get
flutter run
```

### Error: "Build failed"
- Check platform-specific setup (see FIREBASE_SETUP.md)
- For Android: Ensure `google-services.json` is in `android/app/`
- For iOS: Run `cd ios && pod install`

## Common Commands

```bash
# Check Flutter setup
flutter doctor

# Analyze code for errors
flutter analyze

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Run with verbose output (for debugging)
flutter run -v
```

## What to Expect

1. **First Run**: App will show login screen
2. **Register**: Click "Sign Up" to create account
3. **Login**: Use your credentials
4. **Dashboard**: You'll see the dashboard after login

## Still Having Issues?

Check `TROUBLESHOOTING.md` for detailed solutions.
