# Firebase Setup Guide for Flutter

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" or select existing project
3. Follow the setup wizard

## Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Enable **Email/Password** sign-in method:
   - Click on "Email/Password"
   - Toggle "Enable" to ON
   - Click "Save"

## Step 3: Enable Firestore

1. Go to **Firestore Database**
2. Click **Create Database**
3. Choose **Start in test mode** (for development)
4. Select a location
5. Click **Enable**

## Step 4: Add Firebase to Flutter App

### For Android

1. In Firebase Console, click the Android icon
2. Register your app:
   - Android package name: `com.example.placement_readiness_analyzer`
   - App nickname (optional)
   - Click "Register app"
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Update `android/build.gradle`:
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```
6. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### For iOS

1. In Firebase Console, click the iOS icon
2. Register your app:
   - iOS bundle ID: `com.example.placementReadinessAnalyzer`
   - App nickname (optional)
   - Click "Register app"
3. Download `GoogleService-Info.plist`
4. Open Xcode and add it to the Runner project
5. Update `ios/Podfile`:
   ```ruby
   platform :ios, '12.0'
   ```
6. Run `cd ios && pod install`

### For Web

1. In Firebase Console, click the Web icon
2. Register your app
3. Copy the Firebase configuration
4. Create `lib/firebase_options.dart` (or use FlutterFire CLI)

## Step 5: Use FlutterFire CLI (Recommended)

The easiest way to configure Firebase:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will:
- Automatically detect your Firebase projects
- Generate `lib/firebase_options.dart`
- Configure all platforms

## Step 6: Update main.dart

If using FlutterFire CLI, update `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

## Step 7: Firestore Security Rules

Update Firestore rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Student analyses - users can only access their own
    match /student_analyses/{analysisId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 8: Test Authentication

1. Run the app: `flutter run`
2. Try registering a new account
3. Check Firebase Console > Authentication to see the user
4. Check Firestore > users collection to see the profile

## Troubleshooting

### Android: "google-services.json not found"
- Make sure the file is in `android/app/`
- Check `android/app/build.gradle` has the plugin applied

### iOS: "GoogleService-Info.plist not found"
- Add the file in Xcode (not just copy to folder)
- Make sure it's added to the Runner target

### "FirebaseApp not initialized"
- Make sure `Firebase.initializeApp()` is called before `runApp()`
- Check that `firebase_options.dart` exists (if using FlutterFire CLI)

### Authentication not working
- Verify Email/Password is enabled in Firebase Console
- Check Firestore rules allow authenticated users
- Verify API keys are correct

## Next Steps

After setup:
1. Test login/register flow
2. Verify user profiles are created in Firestore
3. Test analysis storage with user context
4. Update backend to filter analyses by user ID

