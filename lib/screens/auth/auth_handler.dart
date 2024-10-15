import 'package:Kohr_Admin/dashboard_screen.dart';
import 'package:Kohr_Admin/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('An error occurred. Please try again later.'),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, show the dashboard
          return const DashBoard();
        } else {
          // User is not logged in, show the login screen
          return const LoginScreen();
        }
      },
    );
  }
}
