import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/assessment/assessment_screen.dart';
import '../screens/results_screen.dart';
import '../screens/history/reports_history_screen.dart';
import '../models/analysis_result.dart';

enum DashboardPage {
  dashboard,
  assessment,
  report,
  history,
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
  String? _currentUserId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _analysisResult = widget.analysisResult;
    // Track current user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = authProvider.user?.uid;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if user has changed (e.g., after sign out/in)
    final authProvider = Provider.of<AuthProvider>(context);
    final newUserId = authProvider.user?.uid;
    
    // If user changed, reset state and go to dashboard
    if (_currentUserId != newUserId) {
      _currentUserId = newUserId;
      if (mounted) {
        setState(() {
          _currentPage = DashboardPage.dashboard;
          _analysisResult = null;
        });
      }
    }
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
      case DashboardPage.history:
        return const ReportsHistoryScreen();
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
    final isWide = MediaQuery.of(context).size.width >= 900;

    final sidebar = _buildSidebar(
      context,
      userName: userName,
      userEmail: userEmail,
      onSignOut: authProvider.signOut,
      closeDrawer: () {
        if (!isWide && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: isWide
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: const Text('SkillGap AI'),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
      drawer: isWide ? null : sidebar,
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 260,
              child: sidebar,
            ),
          Expanded(
            child: _getCurrentPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context, {
    required String userName,
    required String userEmail,
    required Future<void> Function() onSignOut,
    VoidCallback? closeDrawer,
  }) {
    return Drawer(
      elevation: 4,
      child: SafeArea(
        child: Column(
          children: [
            // Logo Section
            Container(
              padding: const EdgeInsets.all(20),
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
                    onTap: closeDrawer,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    icon: Icons.assessment_outlined,
                    label: 'Assessment',
                    page: DashboardPage.assessment,
                    onTap: closeDrawer,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Analysis Report',
                    page: DashboardPage.report,
                    enabled: _analysisResult != null,
                    onTap: closeDrawer,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context,
                    icon: Icons.history_outlined,
                    label: 'Previous Reports',
                    page: DashboardPage.history,
                    onTap: closeDrawer,
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
                        await onSignOut();
                        closeDrawer?.call();
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
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required DashboardPage page,
    bool enabled = true,
    VoidCallback? onTap,
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
              ? () {
                  _navigateToPage(page);
                  onTap?.call();
                }
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

