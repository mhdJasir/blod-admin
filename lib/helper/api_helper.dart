import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:blog/helper/image_helper.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiCallHelper {
  static bool isSessionActive(http.Response response) {
    if (response.statusCode != 200) return true;
    final data = jsonDecode(response.body);
    if (data['statusCode'] == 500 || data['statusCode'] == 700) {
      return false;
    }
    return true;
  }

  static Future<Map<String, dynamic>?> getApi(
      {path, bool isStaticToken = false}) async {
    Uri uri = Uri();
    try {
      var headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
      };
      final response = await http.get(uri, headers: headers);
      return tryDecode(response.body);
    } on SocketException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> postApi({
    path,
    Map<String, dynamic>? args,
    bool isStaticToken = false,
    bool addBranchId = true,
  }) async {
    Uri uri = Uri();
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    Map<String, dynamic> body = {};
    if (args != null) {
      args.forEach((key, value) {
        body[key] = value;
      });
    }
    try {
      String encodedBody = json.encode(body);
      final response = await http.post(
        uri,
        headers: headers,
        body: encodedBody,
      );

      final bool isOnSession = isSessionActive(response);
      return tryDecode(response.body);
    } on SocketException catch (_) {
      rethrow;
    } on TimeoutException catch (e, _) {
      return postApi(path: path, args: args, isStaticToken: isStaticToken);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> postApiWithFile(
      {path,
      Map body = const {},
      required ImageData imageData,
      String uploadArgument = "image"}) async {
    Uri uri = Uri();
    try {
      Map<String, String> headers = {};
      var request = http.MultipartRequest("POST", uri);
      body.forEach((key, value) {
        if (key != "image") {
          request.fields[key] = "${value ?? ''}";
        }
      });
      request.headers.addAll(headers);
      try {
        final stream = ByteStream.fromBytes(imageData.bytes);
        request.files.add(
          http.MultipartFile(
            uploadArgument,
            stream,
            imageData.file.size,
            filename: imageData.file.name,
          ),
        );
      } catch (e, _) {
        rethrow;
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final bool isOnSession = isSessionActive(response);
      return tryDecode(response.body);
    } on SocketException catch (_) {
      rethrow;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> postApiWithFiles(
      {path,
      Map body = const {},
      required List<ImageData> imageData,
      String uploadArgument = "image"}) async {
    Uri uri = Uri();
    try {
      Map<String, String> headers = {};
      var request = http.MultipartRequest("POST", uri);
      body.forEach((key, value) {
        if (key != "image") {
          request.fields[key] = "${value ?? ''}";
        }
      });
      request.headers.addAll(headers);
      try {
        for (int i = 0; i < imageData.length; i++) {
          final element = imageData[i];
          final stream = ByteStream.fromBytes(element.bytes);
          request.files.add(
            http.MultipartFile(
              "$uploadArgument[$i]",
              stream,
              element.file.size,
              filename: element.file.name,
            ),
          );
        }
      } catch (e, _) {
        rethrow;
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return tryDecode(response.body);
    } on SocketException catch (_) {
      rethrow;
    } catch (e) {
      return null;
    }
  }

  static dynamic tryDecode(data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }
}

class InvalidSession implements Exception {
  InvalidSession({
    this.message = "Your session has expired. please login again",
    this.code = "600",
  });

  final String message;
  final String? code;
}
