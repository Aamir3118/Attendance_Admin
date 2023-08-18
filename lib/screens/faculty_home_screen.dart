import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FacultyHomeScreen extends StatefulWidget {
  const FacultyHomeScreen({super.key});

  @override
  State<FacultyHomeScreen> createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen> {
  FirebaseAuth user = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              try {
                await user.signOut();
              } catch (e) {
                e.toString();
              }
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
          )
        ],
      ),
    );
  }
}
