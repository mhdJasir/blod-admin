import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

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
    Uri uri =Uri.parse(path);
    try {
      var headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
      };
      print(uri);
      final response = await http.get(uri, headers: headers);
      print(response.body);
      final bool isOnSession = isSessionActive(response);
      if (!isOnSession) {
        return null;
      }
      return tryDecode(response.body);
    } on SocketException catch (_) {
      print('ApiCallHelper.getApi Socket Exception');
      rethrow;
    } catch (e) {
      print("Error   : $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> postApi({
    path,
    Map<String, dynamic>? args,
    bool isStaticToken = false,
    bool addBranchId = true,
    bool shouldLog = false,
  }) async {
    Uri uri =Uri(path: path);
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
      if (shouldLog && response.body.length < 1000) {
        log(response.body, name: 'Response');
      } else if (shouldLog) {
        print('Too much to print');
      }
      final bool isOnSession = isSessionActive(response);
      if (!isOnSession) {
        return null;
      }
      return tryDecode(response.body);
    } on SocketException catch (_) {
      rethrow;
    } on TimeoutException catch (e, _) {
      return postApi(path: path, args: args, isStaticToken: isStaticToken);
    } catch (e) {
      rethrow;
    }
  }

  // static Future<Map<String, dynamic>?> postApiWithFile(
  //     {path,
  //     Map body = const {},
  //     required ImageData imageData,
  //     String uploadArgument = "image"}) async {
  //   Uri uri = ApiHelper.getUri('$path');
  //   try {
  //     var headers = {
  //       'Authorization': 'Bearer ${currentUser.value?.apiToken}',
  //       'sessionid': currentUser.value?.sessionId ?? '',
  //     };
  //     var request = http.MultipartRequest("POST", uri);
  //     body.forEach((key, value) {
  //       if (key != "image") {
  //         request.fields[key] = "${value ?? ''}";
  //       }
  //     });
  //     request.fields["branch_id"] = "${selectedBranch.value.branchId}";
  //     request.headers.addAll(headers);
  //     try {
  //       final stream = ByteStream.fromBytes(imageData.bytes);
  //       request.files.add(
  //         http.MultipartFile(
  //           uploadArgument,
  //           stream,
  //           imageData.file.size,
  //           filename: imageData.file.name,
  //         ),
  //       );
  //     } catch (e, _) {
  //       rethrow;
  //     }
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //     final bool isOnSession = isSessionActive(response);
  //     if (!isOnSession) {
  //       SessionHelper.mangeInvalidSession(GlobalKey());
  //       return null;
  //     }
  //     return tryDecode(response.body);
  //   } on SocketException catch (_) {
  //     rethrow;
  //   } catch (e) {
  //     return null;
  //   }
  // }
  //
  // static Future<Map<String, dynamic>?> postApiWithFiles(
  //     {path,
  //     Map body = const {},
  //     required List<ImageData> imageData,
  //     String uploadArgument = "image"}) async {
  //   Uri uri = ApiHelper.getUri('$path');
  //   try {
  //     var headers = {
  //       'Authorization': 'Bearer ${currentUser.value?.apiToken}',
  //       'sessionid': currentUser.value?.sessionId ?? '',
  //     };
  //     var request = http.MultipartRequest("POST", uri);
  //     body.forEach((key, value) {
  //       if (key != "image") {
  //         request.fields[key] = "${value ?? ''}";
  //       }
  //     });
  //     request.fields["branch_id"] = "${selectedBranch.value.branchId}";
  //     request.headers.addAll(headers);
  //     try {
  //       for (int i = 0; i < imageData.length; i++) {
  //         final element = imageData[i];
  //         final stream = ByteStream.fromBytes(element.bytes);
  //         request.files.add(
  //           http.MultipartFile(
  //             "$uploadArgument[$i]",
  //             stream,
  //             element.file.size,
  //             filename: element.file.name,
  //           ),
  //         );
  //       }
  //     } catch (e, _) {
  //       rethrow;
  //     }
  //     request.fields.prettyPrint;
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //     if (response.body.length < 10000) print(response.body);
  //     final bool isOnSession = isSessionActive(response);
  //     if (!isOnSession) throw InvalidSession();
  //     return tryDecode(response.body);
  //   } on SocketException catch (_) {
  //     rethrow;
  //   } catch (e) {
  //     return null;
  //   }
  // }

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
