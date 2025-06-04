import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
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
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {
          _max = _controller.value.duration.inSeconds.toDouble();
          _end = _max > 8.0 ? 8.0 : _max;
        });
        _generateThumbnail();
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

  Future<void> _generateThumbnail() async {
    final thumb = await VideoThumbnail.thumbnailFile(
      video: widget.path,
      timeMs: (_start * 1000).toInt(),
      imageFormat: ImageFormat.JPEG,
      quality: 75,
    );
    setState(() {
      _thumbnailPath = thumb;
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

    final double duration = _end - _start;
    final bool isValidDuration = duration >= 3.0 && duration <= 8.0;

    return Scaffold(
      appBar: AppBar(title: const Text('영상 구간 선택')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _togglePlayPause,
              ),
              Text(
                '현재 위치: ${_controller.value.position.inSeconds.toDouble().toStringAsFixed(1)}초 / '
                '선택 구간: ${_start.toStringAsFixed(1)} ~ ${_end.toStringAsFixed(1)}초 '
                '(${duration.toStringAsFixed(1)}초)',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
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
                  double start = values.start;
                  double end = values.end;

                  if (end - start > 8.0) {
                    end = start + 8.0;
                  } else if (end - start < 3.0) {
                    end = start + 3.0;
                  }

                  if (end > _max) {
                    end = _max;
                    start = end - 8.0;
                    if (start < 0) start = 0;
                  }

                  setState(() {
                    _start = start;
                    _end = end;
                    _controller.seekTo(Duration(seconds: _start.toInt()));
                  });
                },
              ),
              const SizedBox(height: 16),
              if (!isValidDuration)
                const Text(
                  '구간 길이는 3초 이상, 8초 이하여야 합니다.',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ElevatedButton(
                onPressed: isValidDuration ? _proceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidDuration ? Colors.blue : Colors.grey,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text("선택한 구간 업로드"),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
