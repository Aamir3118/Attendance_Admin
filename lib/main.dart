import 'package:attendance_admin/manage/add_faculty_screen.dart';
import 'package:attendance_admin/screens/faculty_home_screen.dart';
import 'package:attendance_admin/screens/login_selection_screen.dart';
import 'package:attendance_admin/screens/signin_screen.dart';
import 'package:attendance_admin/screens/splash_screen.dart';
import 'package:attendance_admin/screens/tabs_screen.dart';
import 'package:attendance_admin/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDialogShown = false;
  @override
  Widget build(BuildContext context) {
    //final user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance System',
      theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Theme.of(context).primaryColor),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            color: Colors.blue.shade800,
            elevation: 0,
          ),
          iconTheme: IconThemeData(color: Colors.blue),
          buttonTheme: ButtonThemeData(buttonColor: Colors.blue)),
      home: SplashScreen(),
    );
    // return FutureBuilder<DocumentSnapshot>(
    //     future: adminRef.get(),
    //     builder: (ctx, adminsnapshot) {
    //       if (adminsnapshot.hasData && adminsnapshot.data!.exists) {
    //         print("ID: {$facultyRef}");
    //         return AdminHomeScreen();
    //       } else {
    //         // if (!isDialogShown) {
    //         //   isDialogShown = true;
    //         //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //         //     _showSignInDialog(ctx);
    //         //   });
    //         //}
    //         print("You are not an admin. Please sign in as an admin.");
    //         return SignInScreen();
    //       }
    //     });
  }
}

void _showSignInDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Not an Admin'),
      content: Text('You are not an admin. Please sign in as an admin.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text('Ok'),
        ),
      ],
    ),
  );
}
