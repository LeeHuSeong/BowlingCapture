import 'package:flutter/material.dart';
import 'home/splash_screen.dart';

void main() {
  runApp(const BowlingCaptureApp());
}

class BowlingCaptureApp extends StatelessWidget {
  const BowlingCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bowling Capture',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // 첫 화면: SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
