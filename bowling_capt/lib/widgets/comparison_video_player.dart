import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

class ComparisonVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ComparisonVideoPlayer({required this.videoUrl, super.key});

  @override
  State<ComparisonVideoPlayer> createState() => _ComparisonVideoPlayerState();
}

class _ComparisonVideoPlayerState extends State<ComparisonVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() => _initialized = true);
      }).catchError((e) {
        print("🎥 비디오 초기화 오류: $e");
        setState(() => _initialized = true);
      });
  }

  @override
  void didUpdateWidget(covariant ComparisonVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.pause();
      _controller.dispose();
      _initialized = false;
      _initializeController();
    }
  }

  @override
  void dispose() {
    try {
      if (_controller.value.isInitialized) {
        _controller.pause();
      }
      _controller.dispose();
    } catch (e) {
      print("🧨 dispose 오류: $e");
    }
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.value.hasError) {
      return Center(
        child: Text("비디오 로딩 실패: ${_controller.value.errorDescription ?? '알 수 없는 오류'}"),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        if (!_controller.value.isPlaying)
          const Icon(Icons.play_arrow, size: 64, color: Colors.white70),
      ],
    );
  }
}