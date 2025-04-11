import 'dart:io';

class LSTMService {
  /// 키포인트 데이터를 기반으로 LSTM이 생성한 피드백을 반환한다고 가정
  static Future<String> predictFeedback(List<dynamic> keypoints) async {
    // 예: LSTM 결과가 텍스트로 저장되어 있음
    final feedbackFile = File('/storage/emulated/0/Keypoints/feedback.txt');

    if (await feedbackFile.exists()) {
      return await feedbackFile.readAsString();
    } else {
      return '분석 결과를 불러올 수 없습니다.';
    }
  }
}
