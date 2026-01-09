import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/analysis_history.dart';
import '../../providers/auth_provider.dart';
import '../results_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onStartAssessment;

  const DashboardScreen({
    super.key,
    this.onStartAssessment,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<AnalysisHistory> _recentAnalyses = [];
  bool _isLoadingHistory = true;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    // Get current user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _lastUserId = authProvider.user?.uid;
    _loadRecentAnalyses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload analyses when user changes (backup check)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    
    if (_lastUserId != currentUserId && currentUserId != null && _lastUserId != null) {
      _lastUserId = currentUserId;
      _loadRecentAnalyses();
    }
  }

  Future<void> _loadRecentAnalyses() async {
    try {
      final analyses = await ApiService.getUserAnalyses();
      setState(() {
        _recentAnalyses = analyses.take(3).toList(); // Show only 3 most recent
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Text(
                'Hi, Candidate!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's build your placement readiness roadmap today.",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
              ),
              const SizedBox(height: 48),
              // Main CTA Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.assessment_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ready to Start?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get your personalized readiness assessment',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: widget.onStartAssessment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Start First Assessment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Recent Reports Section
              if (_recentAnalyses.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Reports',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to history - this will be handled by parent
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._recentAnalyses.map((analysis) => _buildRecentReportCard(context, analysis)),
                const SizedBox(height: 32),
              ],
              // Features Section
              Text(
                'What You\'ll Get',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            context,
                            icon: Icons.insights_outlined,
                            title: 'AI Analysis',
                            description:
                                'Comprehensive assessment of your placement readiness',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureCard(
                            context,
                            icon: Icons.track_changes_outlined,
                            title: 'Skill Gaps',
                            description:
                                'Identify areas that need improvement',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureCard(
                            context,
                            icon: Icons.calendar_today_outlined,
                            title: '30-Day Plan',
                            description:
                                'Personalized roadmap for improvement',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildFeatureCard(
                        context,
                        icon: Icons.insights_outlined,
                        title: 'AI Analysis',
                        description:
                            'Comprehensive assessment of your placement readiness',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        context,
                        icon: Icons.track_changes_outlined,
                        title: 'Skill Gaps',
                        description:
                            'Identify areas that need improvement',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: '30-Day Plan',
                        description:
                            'Personalized roadmap for improvement',
                        color: Colors.green,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReportCard(BuildContext context, AnalysisHistory analysis) {
    final color = _getReadinessColor(analysis.readinessLevel);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '${analysis.readinessScore}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        title: Text(
          'Readiness: ${analysis.readinessLevel}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Score: ${analysis.readinessScore}/100',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () {
          if (analysis.fullAnalysis != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsScreen(analysisResult: analysis.fullAnalysis!),
              ),
            );
          }
        },
      ),
    );
  }

  Color _getReadinessColor(String level) {
    switch (level.toLowerCase()) {
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

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

