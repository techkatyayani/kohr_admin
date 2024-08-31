import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kohr_admin/colors.dart';
import 'package:kohr_admin/dashboard_screen.dart';
import 'package:kohr_admin/firebase_options.dart';
import 'package:kohr_admin/screens/auth/auth_handler.dart';
import 'package:kohr_admin/screens/auth/forgot_password.dart';
import 'package:kohr_admin/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KOHR Admin',
      theme: ThemeData(
        fontFamily: 'Sora',
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue, primary: AppColors.primaryBlue),
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashBoard(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
