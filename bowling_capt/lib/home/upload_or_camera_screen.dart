import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'video_editor_screen.dart'; 
import '../services/video_service.dart';

class UploadOrCameraScreen extends StatelessWidget {
  final String style;
  const UploadOrCameraScreen({super.key, required this.style});

  void _pickVideoAndProceed(BuildContext context, String source) async {
    final path = source == 'upload'
        ? await VideoService.pickVideo()
        : await VideoService.captureVideo();

    if (path != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoEditorScreen(path: path, style: style),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$style 스타일 - 영상 선택'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickVideoAndProceed(context, 'upload'),
              icon: const Icon(Icons.upload_file),
              label: const Text('영상 업로드'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _pickVideoAndProceed(context, 'camera'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('카메라로 촬영'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
