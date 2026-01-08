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

