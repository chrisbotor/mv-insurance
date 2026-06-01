import 'package:flutter/material.dart';
import 'screens/admin_screen.dart';

void main() {
  runApp(const BrightPathAdminApp());
}

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
      home: const AdminScreen(),
    );
  }
}