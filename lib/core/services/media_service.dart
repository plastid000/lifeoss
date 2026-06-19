import 'package:image_picker/image_picker.dart';

class MediaService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndSaveImage() async {
    // Pick an image from the gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // In production, we should copy this to getApplicationDocumentsDirectory()
      // But for now, returning the cache path works perfectly.
      return image.path;
    }
    return null;
  }
}
