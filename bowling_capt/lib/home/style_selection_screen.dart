import 'package:flutter/material.dart';
import 'upload_or_camera_screen.dart';

class StyleSelectionScreen extends StatelessWidget {
  const StyleSelectionScreen({super.key});

  void _navigateToNext(BuildContext context, String style) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadOrCameraScreen(style: style),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = ['스트로커', '투핸드', '덤리스', '크랭커'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('스타일 선택'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '당신의 스타일을 선택하세요!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ...styles.map((style) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () => _navigateToNext(context, style),
                    child: Text(style, style: const TextStyle(fontSize: 18)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
