import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/assessment/assessment_screen.dart';
import '../screens/results_screen.dart';
import '../models/analysis_result.dart';

enum DashboardPage {
  dashboard,
  assessment,
  report,
}

class DashboardLayout extends StatefulWidget {
  final DashboardPage initialPage;
  final AnalysisResult? analysisResult;

  const DashboardLayout({
    super.key,
    this.initialPage = DashboardPage.dashboard,
    this.analysisResult,
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  DashboardPage _currentPage = DashboardPage.dashboard;
  AnalysisResult? _analysisResult;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _analysisResult = widget.analysisResult;
  }

  void _navigateToPage(DashboardPage page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _setAnalysisResult(AnalysisResult result) {
    setState(() {
      _analysisResult = result;
      _currentPage = DashboardPage.report;
    });
  }

  Widget _getCurrentPage() {
    switch (_currentPage) {
      case DashboardPage.dashboard:
        return DashboardScreen(
          onStartAssessment: () => _navigateToPage(DashboardPage.assessment),
        );
      case DashboardPage.assessment:
        return AssessmentScreen(
          onAnalysisComplete: _setAnalysisResult,
        );
      case DashboardPage.report:
        if (_analysisResult != null) {
          return ResultsScreen(analysisResult: _analysisResult!);
        }
        return const DashboardScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProfile = authProvider.userProfile;
    final userName = userProfile?['name'] ?? 'User';
    final userEmail = authProvider.user?.email ?? '';

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SkillGap AI',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        page: DashboardPage.dashboard,
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context,
                        icon: Icons.assessment_outlined,
                        label: 'Assessment',
                        page: DashboardPage.assessment,
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        context,
                        icon: Icons.description_outlined,
                        label: 'Analysis Report',
                        page: DashboardPage.report,
                        enabled: _analysisResult != null,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // User Profile Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authProvider.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _getCurrentPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required DashboardPage page,
    bool enabled = true,
  }) {
    final isActive = _currentPage == page;
    final color = enabled
        ? (isActive ? Theme.of(context).primaryColor : Colors.grey[700])
        : Colors.grey[400];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: isActive
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: enabled
              ? () => _navigateToPage(page)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

