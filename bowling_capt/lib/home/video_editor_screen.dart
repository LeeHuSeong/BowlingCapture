import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'home_screen.dart';

class VideoEditorScreen extends StatefulWidget {
  final String path;
  final String style;

  const VideoEditorScreen({super.key, required this.path, required this.style});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late VideoPlayerController _controller;
  double _start = 0.0;
  double _end = 0.0;
  double _max = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {
          _max = _controller.value.duration.inSeconds.toDouble();
          _end = _max;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _proceed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          style: widget.style,
          source: 'upload',
          editedVideoPath: widget.path,
          startTime: _start,
          endTime: _end,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영상 구간 선택')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            const SizedBox(height: 16),

            // 슬라이더는 여기 ↓ 영상 아래에 위치
            Text("시작: ${_start.toStringAsFixed(1)} / 끝: ${_end.toStringAsFixed(1)}"),
            RangeSlider(
              min: 0,
              max: _max,
              values: RangeValues(_start, _end),
              onChanged: (values) {
                setState(() {
                  _start = values.start;
                  _end = values.end;
                });
              },
            ),

            ElevatedButton(
              onPressed: _proceed,
              child: const Text("선택한 구간 업로드"),
            ),
          ],
        ),
      ),
    );
  }
}
