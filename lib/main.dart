import 'package:Kohr_Admin/firebase_options.dart';
import 'package:Kohr_Admin/screens/auth/auth_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
      title: 'Kohr Admin',
      theme: ThemeData(
        fontFamily: 'Sora',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff09254A),
          primary: const Color(0xff09254A),
        ),
        useMaterial3: false,
      ),
      home: AuthWrapper(),
      //   initialRoute: '/',
      //   routes: {
      //     '/': (context) => const AuthWrapper(),
      //     '/login': (context) => const LoginScreen(),
      //     '/dashboard': (context) => const DashBoard(),
      //   },
    );
  }
}
