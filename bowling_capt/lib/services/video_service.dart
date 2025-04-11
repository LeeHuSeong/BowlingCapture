import 'package:image_picker/image_picker.dart';

class VideoService {
  static Future<String?> pickVideo() async {
    final result = await ImagePicker().pickVideo(source: ImageSource.gallery);
    return result?.path;
  }

  static Future<String?> captureVideo() async {
    final result = await ImagePicker().pickVideo(source: ImageSource.camera);
    return result?.path;
  }
}