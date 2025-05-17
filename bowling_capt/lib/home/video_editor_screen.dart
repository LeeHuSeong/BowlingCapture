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
        _controller.play();
        _controller.addListener(_onVideoTick);
      });
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoTick);
    _controller.dispose();
    super.dispose();
  }

  void _onVideoTick() {
  final position = _controller.value.position.inSeconds.toDouble();

  if (position >= _end) {
    _controller.pause();
  }
}

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
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
  if (!_controller.value.isInitialized) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  return Scaffold(
    appBar: AppBar(title: const Text('영상 구간 선택')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          const SizedBox(height: 8),
          //동영상 위치 조정 위젯
          //VideoProgressIndicator(_controller, allowScrubbing: true),
          IconButton(
            icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
          ),

          // ⏱️ 현재 재생 시간 & 선택 구간 표시
          Text(
            '현재 위치: ${_controller.value.position.inSeconds.toDouble().toStringAsFixed(1)}초 / '
            '선택 구간: ${_start.toStringAsFixed(1)} ~ ${_end.toStringAsFixed(1)}초',
            style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // 🎯 슬라이더로 시작/끝 구간 설정
            RangeSlider(
              min: 0,
              max: _max,
              divisions: _max.toInt(),
              values: RangeValues(_start, _end),
              labels: RangeLabels(
                _start.toStringAsFixed(1),
                _end.toStringAsFixed(1),
              ),
              onChanged: (values) {
                setState(() {
                  _start = values.start;
                  _end = values.end;
                  _controller.seekTo(Duration(seconds: _start.toInt()));
                });
              },
            ),
            const SizedBox(height: 16),
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
