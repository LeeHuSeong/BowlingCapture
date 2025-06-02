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
    final styles = [
      {'name': '스트로커', 'color': Colors.blue},
      {'name': '투핸드','color': Colors.green},
      {'name': '덤리스', 'color': Colors.orange},
      {'name': '크랭커','color': Colors.red},
    ];

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
                children: styles.map((styleData) {
                  final String name = styleData['name'] as String;
                  final Color color = styleData['color'] as Color;

                  return InkWell(
                    onTap: () => _navigateToNext(context, name),
                    child: Card(
                      color: color.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
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
