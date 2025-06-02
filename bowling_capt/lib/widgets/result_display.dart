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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟡 점수
                  Row(
                    children: [
                      Text(
                        '정확도 점수: ${result.score.toStringAsFixed(1)}점',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      const Tooltip(
                        message: 'AI가 올바르다고 판단한 프레임 비율입니다.\n높을수록 정확한 자세입니다.',
                        child: Icon(Icons.help_outline, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // DTW 점수
                  Row(
                    children: [
                      Text(
                        'DTW 점수: ${result.dtwScore.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      const Tooltip(
                        message: '전문가 동작과의 유사도를 나타냅니다.\n낮을수록 더 비슷한 자세입니다.',
                        child: Icon(Icons.help_outline, size: 18),
                      ),
                    ],
                  ),
                  // 🔵 영상 (세로 비율 유지 + 높이 제한)
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.55,
                      ),
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: ComparisonVideoPlayer(videoUrl: videoUrl),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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

                  const SizedBox(height: 30), // 추가 공간 확보
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
