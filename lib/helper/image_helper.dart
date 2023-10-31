import 'package:file_picker/file_picker.dart';

class ImageHelper {
  ImageHelper._();

  static ImageHelper get instance => ImageHelper._();
  PlatformFile? pickedFile;

  Future<ImageData?> pickAFileAsBytes() async {
    var result = await FilePicker.platform.pickFiles(withReadStream: true);
    if (result == null) return null;
    pickedFile = result.files.single;
    late ImageData imageData;
    Stream<List<int>>? data = pickedFile?.readStream;
    if (data == null) return null;
    await for (var element in data) {
      imageData = ImageData(file: pickedFile!, bytes: element);
    }
    return imageData;
  }

  Future<List<ImageData>?> pickFilesAsBytes() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withReadStream: true,
      );
      List<ImageData> images = [];
      if (result == null) return [];
      for (var file in result.files) {
        Stream<List<int>>? data = file.readStream;
        if (data == null) continue;
        await for (var element in data) {
          images.add(ImageData(file: file, bytes: element));
        }
      }
      return images;
    } catch (e, s) {
      rethrow;
    }
  }
}

class ImageData {
  final PlatformFile file;
  final List<int> bytes;

  ImageData({
    required this.file,
    required this.bytes,
  });
}
