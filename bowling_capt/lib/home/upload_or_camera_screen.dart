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
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '영상을 업로드하거나\n직접 촬영하여 분석을 시작하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 40),

            // 업로드 버튼
            GestureDetector(
              onTap: () => _pickVideoAndProceed(context, 'upload'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.upload_file, size: 28, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('영상 업로드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 카메라 버튼
            GestureDetector(
              onTap: () => _pickVideoAndProceed(context, 'camera'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt, size: 28, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('카메라로 촬영', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              '💡 업로드한 영상은 자세 분석 후 삭제됩니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
