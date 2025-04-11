import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class ResultDisplay extends StatelessWidget {
  final AnalysisResult result;

  const ResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.blueGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              '분석 결과',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('DTW 점수: ${result.dtwScore.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('자세 피드백:\n${result.feedback}'),
          ],
        ),
      ),
    );
  }
}
