import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/student_profile.dart';
import '../../services/api_service.dart';
import '../../models/analysis_result.dart';

class AssessmentScreen extends StatefulWidget {
  final Function(AnalysisResult) onAnalysisComplete;

  const AssessmentScreen({
    super.key,
    required this.onAnalysisComplete,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Personal Information Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _collegeController = TextEditingController();
  final _qualificationController = TextEditingController();

  // Academic Information Controllers
  final _cgpaController = TextEditingController();
  final _attendanceController = TextEditingController();

  // Achievements Controllers
  final _hackathonsController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _certificationsController = TextEditingController();

  // Skills & Experience Controllers
  final _dsaPracticeController = TextEditingController();
  final _internshipCountController = TextEditingController();
  final _mockInterviewController = TextEditingController();
  final _resumeScoreController = TextEditingController();

  String _selectedQualification = 'B.Tech';
  String _selectedDepartment = 'Computer Science';
  double _resumeScoreSlider = 50.0;

  final List<String> _qualifications = [
    'B.Tech',
    'M.Tech',
    'Diploma',
    'B.E',
    'M.E',
    'B.Sc',
    'M.Sc',
    'BCA',
    'MCA',
    'Other'
  ];

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Aerospace Engineering',
    'Chemical Engineering',
    'Data Science',
    'Artificial Intelligence',
    'Cybersecurity',
    'Software Engineering',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _collegeController.dispose();
    _qualificationController.dispose();
    _cgpaController.dispose();
    _attendanceController.dispose();
    _hackathonsController.dispose();
    _technologiesController.dispose();
    _certificationsController.dispose();
    _dsaPracticeController.dispose();
    _internshipCountController.dispose();
    _mockInterviewController.dispose();
    _resumeScoreController.dispose();
    super.dispose();
  }

  Future<void> _analyzeProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = StudentProfile(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        college: _collegeController.text.trim(),
        qualification: _selectedQualification,
        department: _selectedDepartment,
        cgpa: double.parse(_cgpaController.text),
        attendance: double.parse(_attendanceController.text),
        hackathons: _hackathonsController.text.trim(),
        technologies: _technologiesController.text.trim(),
        certifications: _certificationsController.text.trim(),
        dsaPractice: double.parse(_dsaPracticeController.text),
        internshipCount: int.parse(_internshipCountController.text),
        mockInterviewScore: double.parse(_mockInterviewController.text),
        resumeScore: _resumeScoreSlider,
      );

      final result = await ApiService.analyzeProfile(profile);
      widget.onAnalysisComplete(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Student Details & Assessment',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in your complete details to get a personalized AI analysis',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),
                // Form Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Personal Information
                          _buildSectionHeader(
                            context,
                            icon: Icons.person_outline,
                            title: 'Personal Information',
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Student Name',
                            hint: 'Enter your full name',
                            icon: Icons.person,
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _locationController,
                                  label: 'Location',
                                  hint: 'City, State',
                                  icon: Icons.location_on_outlined,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _collegeController,
                                  label: 'College',
                                  hint: 'College/University name',
                                  icon: Icons.school_outlined,
                                  isRequired: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'Qualification',
                                  value: _selectedQualification,
                                  items: _qualifications,
                                  icon: Icons.workspace_premium_outlined,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedQualification = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'Department',
                                  value: _selectedDepartment,
                                  items: _departments,
                                  icon: Icons.business_outlined,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDepartment = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Section 2: Academic Performance
                          _buildSectionHeader(
                            context,
                            icon: Icons.school_outlined,
                            title: 'Academic Performance',
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberField(
                                  controller: _cgpaController,
                                  label: 'CGPA',
                                  hint: '0.0 - 10.0',
                                  icon: Icons.grade_outlined,
                                  min: 0.0,
                                  max: 10.0,
                                  isDecimal: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberField(
                                  controller: _attendanceController,
                                  label: 'Attendance (%)',
                                  hint: '0 - 100',
                                  icon: Icons.calendar_today_outlined,
                                  min: 0.0,
                                  max: 100.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Section 3: Achievements
                          _buildSectionHeader(
                            context,
                            icon: Icons.emoji_events_outlined,
                            title: 'Achievements',
                          ),
                          const SizedBox(height: 24),
                          _buildMultiLineTextField(
                            controller: _hackathonsController,
                            label: 'Hackathons',
                            hint: 'List hackathons participated (comma-separated or one per line)',
                            icon: Icons.code_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildMultiLineTextField(
                            controller: _technologiesController,
                            label: 'Mastered Languages or Technologies',
                            hint: 'List programming languages, frameworks, tools (e.g., Python, React, Docker) - comma-separated or one per line',
                            icon: Icons.code_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildMultiLineTextField(
                            controller: _certificationsController,
                            label: 'Certifications',
                            hint: 'List certifications obtained (comma-separated or one per line)',
                            icon: Icons.verified_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),
                          // Section 4: Skills & Experience
                          _buildSectionHeader(
                            context,
                            icon: Icons.work_outline,
                            title: 'Skills & Experience',
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberField(
                                  controller: _dsaPracticeController,
                                  label: 'DSA Practice Per Week',
                                  hint: 'Days Per Week',
                                  icon: Icons.fitness_center_outlined,
                                  min: 0.0,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildNumberField(
                                  controller: _internshipCountController,
                                  label: 'Internship Count',
                                  hint: 'Number of internships',
                                  icon: Icons.business_center_outlined,
                                  min: 0.0,
                                  isInteger: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberField(
                                  controller: _mockInterviewController,
                                  label: 'Mock Interview Score',
                                  hint: '0.0 - 10.0',
                                  icon: Icons.quiz_outlined,
                                  min: 0.0,
                                  max: 10.0,
                                  isDecimal: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Resume Completeness Score',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Slider(
                                            value: _resumeScoreSlider,
                                            min: 0,
                                            max: 100,
                                            divisions: 100,
                                            label: _resumeScoreSlider.round().toString(),
                                            onChanged: (value) {
                                              setState(() {
                                                _resumeScoreSlider = value;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          width: 60,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${_resumeScoreSlider.round()}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _analyzeProfile,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.auto_awesome, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Start AI Analysis',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildMultiLineTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 3,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
      ),
      maxLines: maxLines,
      textAlignVertical: TextAlignVertical.top,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    double? min,
    double? max,
    bool isDecimal = false,
    bool isInteger = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      inputFormatters: isInteger
          ? [FilteringTextInputFormatter.digitsOnly]
          : [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d+\.?\d{0,2}'),
              ),
            ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        final num = isInteger
            ? int.tryParse(value)
            : double.tryParse(value);
        if (num == null) {
          return 'Please enter a valid number';
        }
        if (min != null && num < min) {
          return 'Value must be at least $min';
        }
        if (max != null && num > max) {
          return 'Value must be at most $max';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }
}
