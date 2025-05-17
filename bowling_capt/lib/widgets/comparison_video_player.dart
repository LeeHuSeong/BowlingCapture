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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    print("🎯 videoUrl: ${widget.videoUrl}");

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() => _initialized = true);
      }).catchError((e) {
        print("🎥 비디오 초기화 오류: $e");
        setState(() => _initialized = true); // 화면에 에러 메시지라도 표시
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
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.value.hasError) {
      return Center(
        child: Text("비디오 로딩 실패: ${_controller.value.errorDescription ?? '알 수 없는 오류'}"),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        const SizedBox(height: 10),
        VideoProgressIndicator(_controller, allowScrubbing: true),
        IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: _togglePlayPause,
        ),
      ],
    );
  }
}
