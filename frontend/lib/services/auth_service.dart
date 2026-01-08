import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore (non-blocking, but wait for it)
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
      }).catchError((e) {
        print('Warning: Could not create user profile: $e');
        // Don't fail registration if Firestore fails
      });

      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login in background (non-blocking)
      _updateLastLogin(userCredential.user!.uid, email).catchError((e) {
        print('Warning: Could not update last_login: $e');
      });

      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else {
        errorMessage = e.message ?? 'Authentication failed';
      }
      print('Firebase Auth Error: ${e.code} - $errorMessage');
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('Sign in error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update last login in background (non-blocking)
  Future<void> _updateLastLogin(String userId, String email) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'last_login': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // If user document doesn't exist, create it
      try {
        await _firestore.collection('users').doc(userId).set({
          'name': 'User',
          'email': email,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e2) {
        print('Warning: Could not create user document: $e2');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

