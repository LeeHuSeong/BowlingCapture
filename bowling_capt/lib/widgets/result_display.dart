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
                  // 🟡 점수 카드 2개 수평 정렬
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreCard(
                        label: '정확도',
                        value: '${result.score.toStringAsFixed(1)}점',
                        tooltip: 'AI가 올바르다고 판단한 프레임의 비율입니다.\n높을수록 더 정확한 자세입니다.',
                      ),
                      _buildScoreCard(
                        label: 'DTW',
                        value: result.dtwScore.toStringAsFixed(2),
                        tooltip: '전문가의 자세와 비교한 유사도입니다.\n낮을수록 더 유사한 동작입니다.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🔵 비교 영상
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
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required String label,
    required String value,
    required String tooltip,
  }) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: tooltip,
              child: const Icon(Icons.help_outline, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
