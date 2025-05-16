import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ComparisonVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ComparisonVideoPlayer({required this.videoUrl, super.key});

  @override
  State<ComparisonVideoPlayer> createState() => _ComparisonVideoPlayerState();
}

class _ComparisonVideoPlayerState extends State<ComparisonVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_controller.value.isInitialized)
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        VideoProgressIndicator(_controller, allowScrubbing: true),
        IconButton(
          icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: _togglePlayPause,
        ),
      ],
    );
  }
}
