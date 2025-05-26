import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/video_service.dart';
import '../widgets/result_display.dart';
import '../models/analysis_result.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String style;
  final String source;
  final String editedVideoPath;
  final double startTime;
  final double endTime;

  const HomeScreen({
    super.key,
    required this.style,
    required this.source,
    required this.editedVideoPath,
    required this.startTime,
    required this.endTime,
  });

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

    final path = widget.editedVideoPath;

    try {
      final uri = Uri.parse('http://10.0.2.2:5000/extract_pose');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('video', path));
      request.fields['start'] = widget.startTime.toString();
      request.fields['end'] = widget.endTime.toString();

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('서버 응답: $responseBody');

      if (response.statusCode != 200) {
        throw Exception('서버 오류: $responseBody');
      }

      final extracted = jsonDecode(responseBody);
      final trimmedVideoPath = extracted['trimmed_video'];

      final analyzeUri = Uri.parse('http://10.0.2.2:5000/analyze_pose');
      final analyzeResponse = await http.post(
        analyzeUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'test_keypoints': extracted['keypoints_path'].replaceAll('\\', '/'),
          'pitch_type': widget.style.toLowerCase(),
          'source_video': trimmedVideoPath,
        }),
      );

      print('분석 응답: ${analyzeResponse.body}');

      if (analyzeResponse.statusCode != 200) {
        throw Exception('분석 실패: ${analyzeResponse.body}');
      }

      final json = jsonDecode(analyzeResponse.body);

      if (!mounted) return;
      setState(() {
        _result = AnalysisResult.fromJson(json).copyWith(videoPath: path);
        _isProcessing = false;
      });

    } catch (e) {
      print('에러 발생: $e');
      if (!mounted) return;
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
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('분석중입니다...', style: TextStyle(fontSize: 16)),
                  ],
                )
              : _result != null
                  ? ResultDisplay(result: _result!)
                  : const Text('분석에 실패했습니다.'),
        ),
      ),
    );
  }
}
