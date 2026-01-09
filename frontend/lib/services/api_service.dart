import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/student_profile.dart';
import '../models/analysis_result.dart';
import '../models/analysis_history.dart';

class ApiService {
  // ============================================
  // ⚠️ IMPORTANT: UPDATE THIS FOR PRODUCTION ⚠️
  // ============================================
  // Replace this with your deployed backend URL
  // Examples:
  // - Render: https://your-app.onrender.com
  // - Railway: https://your-app.railway.app
  // - Heroku: https://your-app.herokuapp.com
  // - Google Cloud Run: https://your-service-xxxxx.run.app
  // - Replit: https://your-app.repl.co
  static const String _productionBackendUrl = ''; // ⬅️ SET YOUR PRODUCTION URL HERE

  // Alternative: Use --dart-define when building
  // flutter build web --dart-define=API_BASE_URL=https://your-backend.com
  static const String _envBackendUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Automatically detect the correct backend URL based on platform and environment
  static String get baseUrl {
    // Priority 1: Use --dart-define if provided
    if (_envBackendUrl.isNotEmpty) {
      return _envBackendUrl;
    }

    // Priority 2: Use hardcoded production URL if set
    if (_productionBackendUrl.isNotEmpty) {
      return _productionBackendUrl;
    }

    // Priority 3: Development URLs based on platform
    if (kIsWeb) {
      // For web, check if we're on localhost (development)
      // In production (Firebase Hosting), this will still be localhost
      // So you MUST set _productionBackendUrl above or use --dart-define
      return 'http://localhost:5000'; // Development only
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:5000';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return 'http://localhost:5000';
    } else {
      // Windows, Linux, macOS desktop
      return 'http://localhost:5000';
    }
  }

  static Future<AnalysisResult> analyzeProfile(StudentProfile profile) async {
    try {
      // Get current user ID for saving to their account
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';
      
      final requestBody = profile.toJson();
      requestBody['user_id'] = userId; // Add user ID to request
      
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return AnalysisResult.fromJson(data['analysis']);
        } else {
          throw Exception(data['error'] ?? 'Analysis failed');
        }
      } else {
        // Try to parse error message
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['error'] ?? 'Server error: ${response.statusCode}');
        } catch (parseError) {
          // If parsing fails, use status code to provide meaningful error
          if (response.statusCode == 429) {
            throw Exception('API quota exceeded. Daily limit reached. Please try again tomorrow.');
          } else if (response.statusCode == 503) {
            throw Exception('Service unavailable. Please check API configuration.');
          } else if (response.statusCode == 400) {
            throw Exception('Invalid request. Please check your input data.');
          } else {
            throw Exception('Server error: ${response.statusCode}. ${response.body}');
          }
        }
      }
    } catch (e) {
      // Re-throw as-is if it's already an Exception with a message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to analyze profile: $e');
    }
  }

  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<AnalysisHistory>> getUserAnalyses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/${user.uid}/analyses'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> analyses = data['analyses'] ?? [];
          return analyses.map((json) => AnalysisHistory.fromJson(json)).toList();
        }
        return [];
      }
      return [];
    } catch (e) {
      print('Error fetching user analyses: $e');
      return [];
    }
  }
}

