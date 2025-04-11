import 'package:flutter/material.dart';
import '../services/video_service.dart';
import '../services/movenet_service.dart';
import '../services/dtw_service.dart';
import '../services/lstm_service.dart';
import '../widgets/result_display.dart';
import '../models/analysis_result.dart';

class HomeScreen extends StatefulWidget {
  final String style;
  final String source; // 'upload' or 'camera'

  const HomeScreen({super.key, required this.style, required this.source});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AnalysisResult? _result;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pickVideoAndAnalyze();
  }

  Future<void> _pickVideoAndAnalyze() async {
  setState(() {
    _isProcessing = true;
    _result = null;
  });

  String? path;

  if (widget.source == 'upload') {
    path = await VideoService.pickVideo();
  } else if (widget.source == 'camera') {
    path = await VideoService.captureVideo();
  }

  if (path == null) {
    setState(() => _isProcessing = false);
    return;
  }

  final keypoints = await MoveNetService.processVideo(path);
  final dtwScore = await DTWService.compareWithReference(keypoints);
  final feedback = await LSTMService.predictFeedback(keypoints);

  setState(() {
    _result = AnalysisResult(
      videoPath: path!,
      dtwScore: dtwScore,
      feedback: feedback,
    );
    _isProcessing = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.style} 분석 결과'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isProcessing
              ? const CircularProgressIndicator()
              : _result != null
                  ? ResultDisplay(result: _result!)
                  : const Text('분석에 실패했습니다.'),
        ),
      ),
    );
  }
}
