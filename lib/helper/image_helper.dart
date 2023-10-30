import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageHelper {
  ImageHelper._();

  static ImageHelper get instance => ImageHelper._();
  final _imagePicker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }
}
