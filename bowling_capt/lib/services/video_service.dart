import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class VideoService {
  static Future<String?> pickVideo() async {
    final result = await ImagePicker().pickVideo(source: ImageSource.gallery);
    return result?.path;
  }

  static Future<String?> captureVideo() async {
    final result = await ImagePicker().pickVideo(source: ImageSource.camera);
    return result?.path;
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
}
