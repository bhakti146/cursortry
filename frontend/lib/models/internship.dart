class Internship {
  final String company;
  final String duration;

  Internship({
    required this.company,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'duration': duration,
    };
  }

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      company: json['company'] ?? '',
      duration: json['duration'] ?? '',
    );
  }
}
