import 'package:attendance_admin/screens/faculty_signin_screen.dart';
import 'package:attendance_admin/screens/signin_screen.dart';
import 'package:flutter/material.dart';

class LoginSelectionScreen extends StatefulWidget {
  const LoginSelectionScreen({super.key});

  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Selection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FacultySignInScreen())); // Navigate to FacultySignInScreen
              },
              child: Text('Faculty Login'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SignInScreen())); // Navigate to AdminSignInScreen
              },
              child: Text('Admin Login'),
            ),
          ],
        ),
      ),
    );
  }
}
