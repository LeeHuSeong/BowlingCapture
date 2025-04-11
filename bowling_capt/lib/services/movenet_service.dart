import 'dart:convert';
import 'dart:io';

class MoveNetService {
  /// 영상 경로를 기반으로 키포인트를 추출한다고 가정 (실제론 Python에서 처리됨)
  static Future<List<dynamic>> processVideo(String videoPath) async {
    // 예시: 영상 경로에 기반해 저장된 .json 키포인트 불러오기
    final fileName = videoPath.split(Platform.pathSeparator).last;
    final keypointFile = File('/storage/emulated/0/Keypoints/${fileName.replaceAll('.mp4', '.json')}');

    if (await keypointFile.exists()) {
      final contents = await keypointFile.readAsString();
      return jsonDecode(contents);  // 예: [[x1,y1,conf1], [x2,y2,conf2], ...] * 프레임 수
    } else {
      throw Exception('Keypoint file not found for $fileName');
    }
  }
}
