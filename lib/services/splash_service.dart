import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/wrapper.dart';

class SplashService {
  void isLogin(BuildContext context) {
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Wrapper(),
        ),
      ),
    );
  }
}
