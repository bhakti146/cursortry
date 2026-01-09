import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Set initial user state
    _user = _authService.currentUser;
    if (_user != null) {
      _loadUserProfile();
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      print('AuthProvider: Auth state changed - ${user?.email ?? "null"}');
      _user = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      // Load profile in background, don't block
      _authService.getUserProfile().then((profile) {
        _userProfile = profile;
        notifyListeners();
      }).catchError((e) {
        print('Error loading user profile: $e');
        // Don't fail if profile load fails
      });
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (result['success'] == true) {
        // Wait a moment for Firebase Auth to fully update
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Get the user from Firebase Auth directly to ensure it's current
        _user = _authService.currentUser;
        
        // Fallback to result user if currentUser is still null
        if (_user == null) {
          _user = result['user'] as User?;
        }
        
        // Ensure we have a user before proceeding
        if (_user == null) {
          print('Warning: User is null after signup');
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _isLoading = false;
        
        // Force immediate notification - this should trigger AuthWrapper rebuild
        print('Sign up successful - User: ${_user?.email}, notifying listeners...');
        notifyListeners();
        
        // Wait another tiny bit to ensure the notification is processed
        await Future.delayed(const Duration(milliseconds: 50));
        
        // Load profile in background (non-blocking)
        _loadUserProfile();
        
        // Final notification to ensure UI is updated
        notifyListeners();
        
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        print('Sign up failed: ${result['error']}');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Sign up error: $e');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        // Set user immediately for instant navigation
        _user = result['user'] as User?;
        _isLoading = false;
        notifyListeners();
        
        // Load profile in background (non-blocking)
        _loadUserProfile();
        
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        print('Sign in failed: ${result['error']}');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Sign in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }
}

