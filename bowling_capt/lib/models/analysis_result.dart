class AnalysisResult {
  final double dtwScore;
  final String feedback;
  final String comparisonVideoFileName;
  final String videoPath;

  AnalysisResult({
    required this.dtwScore,
    required this.feedback,
    required this.comparisonVideoFileName,
    required this.videoPath,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      dtwScore: json['distance'],
      feedback: json['feedback'],
      comparisonVideoFileName: json['comparison_video'],
      videoPath: "",
    );
  }
}
