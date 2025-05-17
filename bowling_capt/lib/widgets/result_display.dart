import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import 'comparison_video_player.dart';

class ResultDisplay extends StatelessWidget {
  final AnalysisResult result;

  const ResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    //final serverIp = "http://192.168.35.231"; //실제 서버 주소
    final serverIp = "http://10.0.2.2:5000"; //에뮬레이터용
    final videoUrl = "$serverIp/video/${result.comparisonVideoFileName}";

    return Column(
      children: [
        Text('정확도 점수: ${result.score.toStringAsFixed(1)}점',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('DTW 점수: ${result.dtwScore.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Text('피드백: ${result.feedback}',
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        ComparisonVideoPlayer(videoUrl: videoUrl),
      ],
    );
  }
}
