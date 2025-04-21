import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'home_screen.dart';
import 'dart:io';

class VideoEditorScreen extends StatefulWidget {
  final String path;
  final String style;

  const VideoEditorScreen({super.key, required this.path, required this.style});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isSaving = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(widget.path));
    setState(() {});
  }

  Future<void> _saveTrimmedVideo() async {
    setState(() => _isSaving = true);

    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {
        setState(() => _isSaving = false);

        if (outputPath != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                style: widget.style,
                source: 'upload',
                editedVideoPath: outputPath, // 자른 영상 경로 전달
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영상 자르기')),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: VideoViewer(trimmer: _trimmer)),
                TrimViewer(
                  trimmer: _trimmer,
                  viewerHeight: 50.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: const Duration(seconds: 8),
                  onChangeStart: (value) => _startValue = value,
                  onChangeEnd: (value) => _endValue = value,
                  onChangePlaybackState: (isPlaying) {
                    setState(() => _isPlaying = isPlaying);
                  },
                ),
                ElevatedButton(
                  onPressed: _saveTrimmedVideo,
                  child: const Text("자른 영상으로 분석 시작"),
                ),
              ],
            ),
    );
  }
}
