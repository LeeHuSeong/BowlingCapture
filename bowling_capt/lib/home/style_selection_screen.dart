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
          children: [
            const SizedBox(height: 30),
            const Text(
              '당신의 스타일을 선택하세요!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: styles.map((style) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => _navigateToNext(context, style),
                    child: Text(style, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
