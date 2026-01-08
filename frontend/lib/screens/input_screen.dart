import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/student_profile.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _attendanceController = TextEditingController();
  final _dsaPracticeController = TextEditingController();
  final _projectsController = TextEditingController();
  final _mockInterviewController = TextEditingController();
  final _resumeScoreController = TextEditingController();

  String _selectedCgpaRange = '7-8';
  String _selectedInternship = 'None';

  final List<String> _cgpaRanges = ['0-5', '5-6', '6-7', '7-8', '8-9', '9-10'];
  final List<String> _internshipOptions = ['None', 'Short', 'Long'];

  @override
  void dispose() {
    _attendanceController.dispose();
    _dsaPracticeController.dispose();
    _projectsController.dispose();
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
        attendance: double.parse(_attendanceController.text),
        cgpaRange: _selectedCgpaRange,
        dsaPractice: int.parse(_dsaPracticeController.text),
        projects: int.parse(_projectsController.text),
        internship: _selectedInternship,
        mockInterview: int.parse(_mockInterviewController.text),
        resumeScore: int.parse(_resumeScoreController.text),
      );

      final result = await ApiService.analyzeProfile(profile);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(analysisResult: result),
          ),
        );
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Readiness Analyzer'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Profile',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your details to get a personalized readiness assessment',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildNumberField(
                controller: _attendanceController,
                label: 'Attendance Percentage',
                hint: '0-100',
                icon: Icons.calendar_today,
                max: 100,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'CGPA Range',
                value: _selectedCgpaRange,
                items: _cgpaRanges,
                icon: Icons.school,
                onChanged: (value) {
                  setState(() {
                    _selectedCgpaRange = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _dsaPracticeController,
                label: 'DSA Practice Frequency (per week)',
                hint: 'e.g., 5',
                icon: Icons.code,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _projectsController,
                label: 'Number of Technical Projects',
                hint: 'e.g., 3',
                icon: Icons.work,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Internship Experience',
                value: _selectedInternship,
                items: _internshipOptions,
                icon: Icons.business_center,
                onChanged: (value) {
                  setState(() {
                    _selectedInternship = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _mockInterviewController,
                label: 'Mock Interview Score',
                hint: '0-100',
                icon: Icons.quiz,
                max: 100,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _resumeScoreController,
                label: 'Resume Completeness Score',
                hint: '0-100',
                icon: Icons.description,
                max: 100,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
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
                    : const Text(
                        'Analyze Readiness',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int? max,
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
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        final num = double.tryParse(value);
        if (num == null) {
          return 'Please enter a valid number';
        }
        if (max != null && num > max) {
          return 'Value must be between 0 and $max';
        }
        if (num < 0) {
          return 'Value cannot be negative';
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
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}


