class AnalysisResult {
  final double dtwScore;
  final double score;
  final String feedback;
  final String comparisonVideoFileName;
  final String videoPath;

  AnalysisResult({
    required this.dtwScore,
    required this.score,
    required this.feedback,
    required this.comparisonVideoFileName,
    required this.videoPath,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      dtwScore: (json['distance'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      feedback: json['feedback'] ?? '',
      comparisonVideoFileName: json['comparison_video'] ?? '',
      videoPath: '',
    );
  }

  AnalysisResult copyWith({
    String? videoPath,
  }) {
    return AnalysisResult(
      dtwScore: dtwScore,
      score: score,
      feedback: feedback,
      comparisonVideoFileName: comparisonVideoFileName,
      videoPath: videoPath ?? this.videoPath,
    );
  }
}
