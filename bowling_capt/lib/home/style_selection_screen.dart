import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart'; // 추가
import 'login_screen.dart';
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

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃 확인'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('로그아웃'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showExampleVideo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ExampleVideoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final styles = ['스트로커', '투핸드', '덤리스', '크랭커'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('스타일 선택'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.black),
            label: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '분석할 구질을 선택해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // 예시 영상 보기 버튼
            ElevatedButton.icon(
              onPressed: () => _showExampleVideo(context),
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('예시 영상 보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1,
                children: styles.map((name) {
                  return GestureDetector(
                    onTap: () => _navigateToNext(context, name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade200, Colors.grey.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '💡구질 선택 후, 해당 구질의 자세를 분석하여 피드백을 제공합니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// 영상 다이얼로그 위젯
class ExampleVideoDialog extends StatefulWidget {
  const ExampleVideoDialog({super.key});

  @override
  State<ExampleVideoDialog> createState() => _ExampleVideoDialogState();
}

class _ExampleVideoDialogState extends State<ExampleVideoDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/cranker_001.MOV')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('크랭커 예시 영상'),
      content: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: _controller.value.isInitialized
            ? VideoPlayer(_controller)
            : const Center(child: CircularProgressIndicator()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
