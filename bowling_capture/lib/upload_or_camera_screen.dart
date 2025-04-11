import 'package:flutter/material.dart';

class UploadOrCameraScreen extends StatelessWidget {
  final String style;
  UploadOrCameraScreen({required this.style});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$style 스타일 선택됨')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: 영상 업로드 로직
              },
              child: Text('영상 업로드'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 카메라 촬영 로직
              },
              child: Text('카메라 촬영'),
            ),
          ],
        ),
      ),
    );
  }
}