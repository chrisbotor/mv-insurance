import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dashboards.dart'; // Make sure this matches where you saved the dashboards file

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Note: Even though the UI says "Corporate Email", we send it as "username" to match the FastAPI backend
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- NEW AUTHENTICATION LOGIC ---
  Future<void> _handleLogin() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog('Please enter both username and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Reach out through the Cloudflare Tunnel to your Beelink cluster
      final response = await http.post(
        Uri.parse('https://api-mv-insure.brightpath-itsolutions.com/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      // 2. Check if the backend verified the password (Status 200 OK)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String userRole = data['role']; // Extract the role from Postgres

        if (!mounted) return;

        // 3. Role-Based Routing
        switch (userRole) {
          case 'Super Admin':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SuperAdminDashboard()));
            break;
          case 'Tier 1 Assessor':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Tier1Dashboard()));
            break;
          case 'Tier 2 Support':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Tier2Dashboard()));
            break;
          default:
            _showErrorDialog('Unknown role assigned to this user.');
        }
      } else {
        // Status code 401: Invalid username or password
        if (!mounted) return;
        _showErrorDialog('Invalid username or password.');
      }
    } catch (e) {
      // Catch network errors (e.g., Beelink is offline, Cloudflare tunnel is down)
      if (!mounted) return;
      _showErrorDialog('Network error. Unable to reach the server.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Quick helper to display errors beautifully
  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      )
    );
  }
  // --- END NEW AUTHENTICATION LOGIC ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.security, size: 48, color: Colors.blueAccent),
                const SizedBox(height: 16),
                const Text(
                  'BrightPath Auth',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to access the CRM',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Username', // Changed from Corporate Email to match backend
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}