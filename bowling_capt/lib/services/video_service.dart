import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class VideoService {
  static Future<String?> pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    return file?.path;
  }

 static Future<String?> captureVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.camera);
    return file?.path;
  }

  static Future<bool> uploadVideoToServer(String filePath) async {
    final uri = Uri.parse("http://192.168.35.231:5000/extract_pose"); // 주소 확인 필요

    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('video', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      print("✅ 업로드 성공");
      return true;
    } else {
      print("❌ 업로드 실패: ${response.statusCode}");
      return false;
    }
  }

   static Future<File?> downloadComparisonVideo() async {
    final url = 'http://10.0.2.2:5000/get_comparison_video'; // 실제 서버 주소로 교체 필요

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/comparison.mp4');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    }
  } catch (e) {
    print('영상 다운로드 실패: $e');
  }

  return null;
}
}
