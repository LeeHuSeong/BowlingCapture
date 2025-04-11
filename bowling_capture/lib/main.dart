import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(BowlingCaptureApp());
}

class BowlingCaptureApp extends StatelessWidget {
  const BowlingCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bowling Capture',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}