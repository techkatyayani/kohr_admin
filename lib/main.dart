import 'package:Kohr_Admin/firebase_options.dart';
import 'package:Kohr_Admin/screens/auth/auth_handler.dart';
import 'package:Kohr_Admin/screens/hire/controller/applicationProvider.dart';
import 'package:Kohr_Admin/screens/hire/controller/hire_dasbord_provider.dart';
import 'package:Kohr_Admin/screens/hire/controller/job_application_provider.dart';
import 'package:Kohr_Admin/screens/hire/hire_dashboard.dart';
import 'package:Kohr_Admin/screens/kpi/feedback-screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JobApplicationProvider()),
        ChangeNotifierProvider(create: (_) => HireDashboardProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kohr Admin',
      theme: ThemeData(
        fontFamily: 'Sora',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff09254A),
          primary: const Color(0xff09254A),
        ),
        useMaterial3: false,
      ),
      // home: const AuthWrapper(),
      home: const HireDashboard(),
      //   initialRoute: '/',
      //   routes: {
      //     '/': (context) => const AuthWrapper(),
      //     '/login': (context) => const LoginScreen(),
      //     '/dashboard': (context) => const DashBoard(),
      //   },
    );
  }
}
