import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/result_dao.dart';
import '../models/analysis_result.dart';

class ResultListScreen extends StatefulWidget {
  const ResultListScreen({super.key});

  @override
  State<ResultListScreen> createState() => _ResultListScreenState();
}

class _ResultListScreenState extends State<ResultListScreen> {
  List<AnalysisResult> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) return;

    final results = await ResultDao.getResultsByUserId(userId);
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이전 분석 결과')),
      body: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final result = _results[index];
          return ListTile(
            title: Text(result.pitchType),
            subtitle: Text('${result.timestamp} | 점수: ${result.score.toStringAsFixed(1)}'),
          );
        },
      ),
    );
  }
}
