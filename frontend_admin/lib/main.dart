import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import the new login screen

void main() {
  runApp(const BrightPathAdminApp());
}

//Testing CI Isolation

class BrightPathAdminApp extends StatelessWidget {
  const BrightPathAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrightPath Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Change this to load the LoginScreen first
      home: const LoginScreen(),
    );
  }
}