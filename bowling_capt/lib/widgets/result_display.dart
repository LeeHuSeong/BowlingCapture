import 'package:flutter/material.dart';
import 'dart:io';
import '../models/analysis_result.dart';
import 'comparison_video_player.dart';

class ResultDisplay extends StatelessWidget {
  final AnalysisResult result;

  const ResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final videoFile = File(result.videoPath); // 추가된 부분

    return Column(
      children: [
        Text('DTW 점수: ${result.dtwScore.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Text('피드백: ${result.feedback}',
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        ComparisonVideoPlayer(videoFile: videoFile),
      ],
    );
  }
}
