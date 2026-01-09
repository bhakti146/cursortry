import 'package:flutter/material.dart';

class AnalysisResult {
  final int readinessScore;
  final String readinessLevel;
  final String summary;
  final List<String> strengths;
  final List<String> weakAreas;
  final List<String> riskFactors;
  final List<String> recommendations;
  final ThirtyDayPlan thirtyDayPlan;

  AnalysisResult({
    required this.readinessScore,
    required this.readinessLevel,
    required this.summary,
    required this.strengths,
    required this.weakAreas,
    required this.riskFactors,
    required this.recommendations,
    required this.thirtyDayPlan,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
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
    
    return AnalysisResult(
      readinessScore: score,
      readinessLevel: json['readiness_level'] ?? 'Low',
      summary: json['summary'] ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      weakAreas: List<String>.from(json['weak_areas'] ?? []),
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      thirtyDayPlan: ThirtyDayPlan.fromJson(json['30_day_plan'] ?? {}),
    );
  }

  Color get readinessColor {
    switch (readinessLevel.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ThirtyDayPlan {
  final WeekPlan week1;
  final WeekPlan week2;
  final WeekPlan week3;
  final WeekPlan week4;

  ThirtyDayPlan({
    required this.week1,
    required this.week2,
    required this.week3,
    required this.week4,
  });

  factory ThirtyDayPlan.fromJson(Map<String, dynamic> json) {
    return ThirtyDayPlan(
      week1: WeekPlan.fromJson(json['week_1'] ?? {}),
      week2: WeekPlan.fromJson(json['week_2'] ?? {}),
      week3: WeekPlan.fromJson(json['week_3'] ?? {}),
      week4: WeekPlan.fromJson(json['week_4'] ?? {}),
    );
  }
}

class WeekPlan {
  final String focus;
  final List<String> tasks;

  WeekPlan({
    required this.focus,
    required this.tasks,
  });

  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    return WeekPlan(
      focus: json['focus'] ?? '',
      tasks: List<String>.from(json['tasks'] ?? []),
    );
  }
}

