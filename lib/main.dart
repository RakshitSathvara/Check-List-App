// This is the main.dart file that serves as the entry point for the Flutter application

import 'package:check_list_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to allow both portrait and landscape
  // This is important for tablet support
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const FactoryChecklistApp());
}

class FactoryChecklistApp extends StatelessWidget {
  const FactoryChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VGPL Checklist App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: AuthService.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}