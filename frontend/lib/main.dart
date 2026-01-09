import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'screens/auth/login_screen.dart';
import 'widgets/dashboard_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => app_auth.AuthProvider(),
      child: MaterialApp(
        title: 'SkillGap AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, _) {
        // Get the user from provider, or fallback to Firebase Auth directly
        final user = authProvider.user ?? FirebaseAuth.instance.currentUser;
        
        // Debug: Print auth state
        if (user != null) {
          print('AuthWrapper: User is authenticated - ${user.email}');
        } else {
          print('AuthWrapper: User is not authenticated');
        }

        // Show loading while checking auth state OR during signup/signin
        if (authProvider.isLoading) {
          print('AuthWrapper: Loading...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If authenticated, show dashboard
        if (user != null) {
          print('AuthWrapper: Showing dashboard for ${user.email}');
          // Use user ID as key to force recreation when user changes
          return DashboardLayout(key: ValueKey(user.uid));
        }

        // If not authenticated, show login
        print('AuthWrapper: Showing login screen');
        return const LoginScreen();
      },
    );
  }
}
