import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import 'comparison_video_player.dart';

class ResultDisplay extends StatelessWidget {
  final AnalysisResult result;

  const ResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final serverIp = "http://10.0.2.2:5000";
    final videoUrl = "$serverIp/video/${result.comparisonVideoFileName}";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟡 점수
              Text(
                '정확도 점수: ${result.score.toStringAsFixed(1)}점',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'DTW 점수: ${result.dtwScore.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              // 🔵 영상
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ComparisonVideoPlayer(videoUrl: videoUrl),
                ),
              ),

              const SizedBox(height: 20),

              // 🔴 피드백
              const Text(
                '피드백:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                result.feedback,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
