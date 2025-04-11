import 'dart:io';

class DTWService {
  /// 키포인트 데이터를 이용해 DTW 유사도 점수를 반환한다고 가정
  static Future<double> compareWithReference(List<dynamic> keypoints) async {
    // 예시: DTW 점수가 Python에서 계산되어 텍스트로 저장되어 있다고 가정
    final dtwFile = File('/storage/emulated/0/Keypoints/dtw_result.txt');

    if (await dtwFile.exists()) {
      final contents = await dtwFile.readAsString();
      return double.tryParse(contents.trim()) ?? -1.0;
    } else {
      // 파일이 없다면 0점 처리
      return 0.0;
    }
  }
}
