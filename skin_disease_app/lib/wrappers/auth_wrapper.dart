import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skin_disease_app/screens/home_screen.dart';
import 'package:skin_disease_app/screens/login_screen.dart';
import 'package:skin_disease_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Listen to Firebase Auth state changes directly for even more responsive UI
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while connection state is still active
        if (snapshot.connectionState == ConnectionState.waiting || authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Check if user is authenticated
        final bool isAuthenticated = snapshot.hasData && snapshot.data != null;
        
        // Apply simple fade transition between auth states
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: isAuthenticated
              ? const HomeScreen(key: ValueKey('home'))
              : const LoginScreen(key: ValueKey('login')),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    );
  }
}
