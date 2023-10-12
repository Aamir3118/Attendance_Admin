import 'dart:async';

import 'package:attendance_admin/screens/wrapper.dart';
import 'package:flutter/material.dart';

import '../services/splash_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // SplashService splashService = SplashService();
  // @override
  // void initState() {
  //   super.initState();
  //   Timer(
  //       const Duration(seconds: 3),
  //       () => Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => const Wrapper())));
  // }

  final String iconImage = "assets/Attendance_System-removebg-preview.png";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //       image: AssetImage("assets/background_image.jpg"),
            //       fit: BoxFit.cover),
            // ),
          ),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              // color: Colors.blue,
              iconImage,
              height: 250,
              width: 250,
            ),
          ),
        ],
      ),
    );
  }
}
