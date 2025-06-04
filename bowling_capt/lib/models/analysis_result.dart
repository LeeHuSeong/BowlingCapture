class AnalysisResult {
  final int? id;
  final int userId;
  final double dtwScore;
  final double score;
  final String feedback;
  final String comparisonVideoFileName;
  final String videoPath;
  final String timestamp;
  final String pitchType;

  AnalysisResult({
    this.id,
    required this.userId,
    required this.dtwScore,
    required this.score,
    required this.feedback,
    required this.comparisonVideoFileName,
    required this.videoPath,
    required this.timestamp,
    required this.pitchType,
  });

  // 서버 응답(JSON) → 객체
  factory AnalysisResult.fromJson(
    Map<String, dynamic> json, {
    required int userId,
    required String videoPath,
    required String pitchType,
    required String timestamp,
  }) {
    return AnalysisResult(
      id: null,
      userId: userId,
      dtwScore: (json['distance'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      feedback: json['feedback'] ?? '',
      comparisonVideoFileName: json['comparison_video'] ?? '',
      videoPath: videoPath,
      timestamp: timestamp,
      pitchType: pitchType,
    );
  }

  // SQLite → 객체
  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      dtwScore: (map['dtw_score'] as num).toDouble(),
      score: (map['accuracy_score'] as num).toDouble(),
      feedback: map['feedback'] ?? '',
      comparisonVideoFileName: map['video_file'] ?? '',
      videoPath: '', // DB에는 저장 안 하므로 외부 처리 필요
      timestamp: map['timestamp'] ?? '',
      pitchType: map['pitch_type'] ?? '',
    );
  }

  // 객체 → SQLite 저장용 Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'dtw_score': dtwScore,
      'accuracy_score': score,
      'feedback': feedback,
      'video_file': comparisonVideoFileName,
      'timestamp': timestamp,
      'pitch_type': pitchType,
    };
  }

  // copyWith 메서드 추가
  AnalysisResult copyWith({
    int? id,
    int? userId,
    double? dtwScore,
    double? score,
    String? feedback,
    String? comparisonVideoFileName,
    String? videoPath,
    String? timestamp,
    String? pitchType,
  }) {
    return AnalysisResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dtwScore: dtwScore ?? this.dtwScore,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
      comparisonVideoFileName: comparisonVideoFileName ?? this.comparisonVideoFileName,
      videoPath: videoPath ?? this.videoPath,
      timestamp: timestamp ?? this.timestamp,
      pitchType: pitchType ?? this.pitchType,
    );
  }
}
