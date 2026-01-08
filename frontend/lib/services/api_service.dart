import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_profile.dart';
import '../models/analysis_result.dart';

class ApiService {
  // Update this to your Flask backend URL
  // For Android emulator, use: 'http://10.0.2.2:5000'
  // For iOS simulator, use: 'http://localhost:5000'
  // For physical device, use your computer's IP: 'http://192.168.1.XXX:5000'
  static const String baseUrl = 'http://localhost:5000';

  static Future<AnalysisResult> analyzeProfile(StudentProfile profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return AnalysisResult.fromJson(data['analysis']);
        } else {
          throw Exception(data['error'] ?? 'Analysis failed');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
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
}

