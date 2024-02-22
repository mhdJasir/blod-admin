import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FileHelper {
  PlatformFile? pickedFile;

  Future<List<ImageData>> pickFilesAsBytes() async {
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

  void download(String url, {String? downloadName}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;
      Uint8List bytes = response.bodyBytes;
      // Encode our file in base64
      base64Encode(bytes);
      // Create the link with the file
      // final anchor =
      //     AnchorElement(href: 'data:application/octet-stream;base64,$base64')
      //       ..target = 'blank';
      // // add the name
      // if (downloadName != null) {
      //   anchor.download = downloadName;
      // }
      // trigger download
      // document.body?.append(anchor);
      // anchor.click();
      // anchor.remove();
      return;
    } on Exception catch (e, s) {
      print(s);
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
