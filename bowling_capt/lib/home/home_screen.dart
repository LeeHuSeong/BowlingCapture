import 'package:flutter/material.dart';
import '../services/video_service.dart';
import '../services/movenet_service.dart';
import '../services/dtw_service.dart';
import '../services/lstm_service.dart';
import '../widgets/result_display.dart';
import '../models/analysis_result.dart';
import 'package:http/http.dart' as http;

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

  late String path;

  final selectedPath = widget.source == 'upload'
      ? await VideoService.pickVideo()
      : await VideoService.captureVideo();

  if (selectedPath == null) {
    setState(() => _isProcessing = false);
    return;
  }

  path = selectedPath;


  try {
    // 1. 서버에 영상 업로드
    final uri = Uri.parse('http://127.0.0.1:5000/extract_pose');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('video', path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    print('서버 응답: $responseBody');

    if (response.statusCode != 200) {
      throw Exception('서버 오류: $responseBody');
    }

    // 2. 기존 로직 (예: keypoints -> DTW -> LSTM)
    final keypoints = await MoveNetService.processVideo(path);
    final dtwScore = await DTWService.compareWithReference(keypoints);
    final feedback = await LSTMService.predictFeedback(keypoints);

    setState(() {
      _result = AnalysisResult(
        videoPath: path,
        dtwScore: dtwScore,
        feedback: feedback,
      );
      _isProcessing = false;
    });
  } catch (e) {
    print('에러 발생: $e');
    setState(() => _isProcessing = false);
  }
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
