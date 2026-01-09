class StudentProfile {
  // Personal Information
  final String name;
  final String location;
  final String college;
  final String collegeTier;
  final String qualification;
  final String department;
  
  // Academic Information
  final double cgpa;
  final double attendance;
  
  // Achievements
  final String hackathons;
  final String technologies;
  final String certifications;
  final String projects;
  
  // Skills & Experience
  final String dsaPracticeFrequency; // daily, weekly, monthly
  final List<Map<String, String>> internships; // List of {company, duration}
  final double mockInterviewScore;
  final double resumeScore;

  StudentProfile({
    required this.name,
    required this.location,
    required this.college,
    required this.collegeTier,
    required this.qualification,
    required this.department,
    required this.cgpa,
    required this.attendance,
    required this.hackathons,
    required this.technologies,
    required this.certifications,
    required this.projects,
    required this.dsaPracticeFrequency,
    required this.internships,
    required this.mockInterviewScore,
    required this.resumeScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'college': college,
      'college_tier': collegeTier,
      'qualification': qualification,
      'department': department,
      'cgpa': cgpa,
      'attendance': attendance,
      'hackathons': hackathons,
      'technologies': technologies,
      'certifications': certifications,
      'projects': projects,
      'dsa_practice_frequency': dsaPracticeFrequency,
      'internships': internships,
      'mock_interview_score': mockInterviewScore,
      'resume_score': resumeScore,
    };
  }
}


