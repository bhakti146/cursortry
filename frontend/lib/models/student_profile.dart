class StudentProfile {
  // Personal Information
  final String name;
  final String location;
  final String college;
  final String qualification;
  final String department;
  
  // Academic Information
  final double cgpa;
  final double attendance;
  
  // Achievements
  final String hackathons;
  final String technologies;
  final String certifications;
  
  // Skills & Experience
  final double dsaPractice;
  final int internshipCount;
  final double mockInterviewScore;
  final double resumeScore;

  StudentProfile({
    required this.name,
    required this.location,
    required this.college,
    required this.qualification,
    required this.department,
    required this.cgpa,
    required this.attendance,
    required this.hackathons,
    required this.technologies,
    required this.certifications,
    required this.dsaPractice,
    required this.internshipCount,
    required this.mockInterviewScore,
    required this.resumeScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'college': college,
      'qualification': qualification,
      'department': department,
      'cgpa': cgpa,
      'attendance': attendance,
      'hackathons': hackathons,
      'technologies': technologies,
      'certifications': certifications,
      'dsa_practice': dsaPractice,
      'internship_count': internshipCount,
      'mock_interview_score': mockInterviewScore,
      'resume_score': resumeScore,
    };
  }
}


