import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ComparisonVideoPlayer extends StatefulWidget {
  final File videoFile;

  const ComparisonVideoPlayer({super.key, required this.videoFile});

  @override
  State<ComparisonVideoPlayer> createState() => _ComparisonVideoPlayerState();
}

class _ComparisonVideoPlayerState extends State<ComparisonVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
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
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const CircularProgressIndicator();
  }
}
