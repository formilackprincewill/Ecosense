// lib/screens/auth_wrapper.dart
import 'package:ecosense/providers/auth_provider.dart';
import 'package:ecosense/screens/auth/login.dart';
import 'package:ecosense/screens/nav_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>(); // u could also use provider.of(context)

    return StreamBuilder<AuthState>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        // Check connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // Check if user is logged in
        if (session != null) {
          return const NavWrapper(); 
        } else {
          // User is not logged in
          // Decide whether to show Onboarding or Login
          // A simple approach: Show Onboarding if it's the first time (needs local storage check)
          // For now, let's direct to Login. You can add logic to show Onboarding first.
          // Example: Use shared_preferences to check if onboarding was completed.
          // For simplicity, we'll navigate to login. You can modify this logic.
          return const SignInPage(); // Or Navigator.pushNamed(context, '/onboarding');
        }
      },
    );
  }
}