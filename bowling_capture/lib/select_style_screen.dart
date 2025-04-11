import 'package:flutter/material.dart';
import 'upload_or_camera_screen.dart';

class SelectStyleScreen extends StatelessWidget {
  final List<String> styles = ['스트로커', '투핸드', '덤리스', '크랭커'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('스타일 선택')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: styles.map((style) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadOrCameraScreen(style: style),
                    ),
                  );
                },
                child: Text(style),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}