import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
  }

  Future<XFile?> pickVideo() async {
    return await _picker.pickVideo(source: ImageSource.gallery);
  }
}
