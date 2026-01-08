# Troubleshooting Flutter Run Issues

## Common Issues and Solutions

### 1. "Firebase not initialized" Error

**Problem**: App crashes with Firebase initialization error

**Solution**: Make sure `firebase_options.dart` exists and is properly configured.

```bash
# If firebase_options.dart is missing, generate it:
flutterfire configure
```

### 2. "Package not found" Errors

**Problem**: Dependencies not installed

**Solution**:
```bash
cd frontend
flutter clean
flutter pub get
```

### 3. "Build failed" on Android

**Problem**: Android build configuration issues

**Solution**:
```bash
cd frontend/android
# Make sure google-services.json is in android/app/
# Update android/build.gradle and android/app/build.gradle
```

### 4. "Build failed" on iOS

**Problem**: iOS configuration issues

**Solution**:
```bash
cd frontend/ios
pod install
# Make sure GoogleService-Info.plist is added in Xcode
```

### 5. App Runs But Shows Blank Screen

**Problem**: Firebase not configured or authentication error

**Solution**:
- Check Firebase Console: Authentication > Sign-in method (Email/Password enabled)
- Check Firestore rules allow authenticated users
- Check `firebase_options.dart` has correct API keys

### 6. "DefaultFirebaseOptions not found"

**Problem**: Missing firebase_options.dart

**Solution**:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 7. Hot Reload Not Working

**Solution**:
```bash
# Stop the app and restart
flutter run
```

### 8. Port Already in Use

**Problem**: Another Flutter app is running

**Solution**:
```bash
# Kill existing Flutter processes
# Or use a different port
flutter run --port 8080
```

## Step-by-Step Debugging

1. **Check Flutter Setup**:
   ```bash
   flutter doctor
   ```
   Fix any issues shown.

2. **Clean and Rebuild**:
   ```bash
   cd frontend
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Check for Errors**:
   ```bash
   flutter analyze
   ```
   Fix any errors (warnings are usually OK).

4. **Check Firebase Configuration**:
   - Verify `lib/firebase_options.dart` exists
   - Check Firebase Console for enabled services
   - Verify API keys are correct

5. **Check Platform-Specific Setup**:
   - **Android**: `google-services.json` in `android/app/`
   - **iOS**: `GoogleService-Info.plist` added in Xcode
   - **Web**: Firebase config in `firebase_options.dart`

## Getting More Information

If the app still won't run, check the full error:

```bash
flutter run -v
```

This shows verbose output with detailed error messages.

## Quick Fix Checklist

- [ ] `flutter pub get` completed successfully
- [ ] `firebase_options.dart` exists in `lib/`
- [ ] Firebase Authentication enabled in Console
- [ ] Firestore Database enabled
- [ ] Platform-specific config files present:
  - [ ] Android: `google-services.json`
  - [ ] iOS: `GoogleService-Info.plist` (added in Xcode)
- [ ] No compilation errors (`flutter analyze`)
- [ ] Flutter doctor shows no critical issues

## Still Not Working?

1. Share the exact error message from `flutter run`
2. Check `flutter doctor` output
3. Verify Firebase project is set up correctly
4. Try running on a different platform (web, if available)

