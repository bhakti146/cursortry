import 'analysis_result.dart';

class AnalysisHistory {
  final String id;
  final DateTime timestamp;
  final int readinessScore;
  final String readinessLevel;
  final AnalysisResult? fullAnalysis;

  AnalysisHistory({
    required this.id,
    required this.timestamp,
    required this.readinessScore,
    required this.readinessLevel,
    this.fullAnalysis,
  });

  factory AnalysisHistory.fromJson(Map<String, dynamic> json) {
    try {
      // Handle readiness_score which might be int, double, or null
      int score = 0;
      if (json['readiness_score'] != null) {
        if (json['readiness_score'] is int) {
          score = json['readiness_score'] as int;
        } else if (json['readiness_score'] is double) {
          score = (json['readiness_score'] as double).round();
        } else {
          score = int.tryParse(json['readiness_score'].toString()) ?? 0;
        }
      }
      
      // Handle timestamp which might be string or DateTime
      DateTime timestampValue = DateTime.now();
      if (json['timestamp'] != null) {
        if (json['timestamp'] is String) {
          timestampValue = DateTime.parse(json['timestamp']);
        } else if (json['timestamp'] is DateTime) {
          timestampValue = json['timestamp'] as DateTime;
        }
      }
      
      return AnalysisHistory(
        id: json['id'] ?? '',
        timestamp: timestampValue,
        readinessScore: score,
        readinessLevel: json['readiness_level'] ?? 'Low',
        fullAnalysis: json['analysis'] != null
            ? AnalysisResult.fromJson(json['analysis'])
            : null,
      );
    } catch (e) {
      print('Error parsing AnalysisHistory: $e');
      return AnalysisHistory(
        id: json['id'] ?? '',
        timestamp: DateTime.now(),
        readinessScore: 0,
        readinessLevel: 'Low',
      );
    }
  }
}

