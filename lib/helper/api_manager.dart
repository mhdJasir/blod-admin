import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  ApiManager() {
    manageConnectivity();
    _requestController.stream.listen(onNewRequest);
  }

  final _requestController = StreamController<ApiRequest>();
  final _requestResponseMap = <ApiRequest, StreamController<ApiResponse>>{};
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final List<ApiRequest> _apiQueue = <ApiRequest>[];
  final _connectivity = Connectivity();
  bool isConnected = false;

  Future<void> onNewRequest(ApiRequest request) async {
    switch (request.apiType) {
      case ApiType.get:
        final response = await request.get();
        final responseController = _requestResponseMap[request];
        if (responseController != null) {
          if (response.apiStatus != ApiStatus.notConnected) {
            _removeCompleted(request);
            responseController.add(response);
          }
        }
      case ApiType.custom:
        if (request.customFutureOperation == null) break;
        final responseController = _requestResponseMap[request];
        if (responseController != null && !responseController.isClosed) {
          try {
            // compute((_)=>_fetchDataIsolate(""),"HGFD").then((value) {
            //   // responseController.add(value);
            //   _removeCompleted(request);
            // });
            _fetchDataIsolate("");
          } catch (e) {
            responseController.add(
              ApiResponse(
                data: e,
                apiStatus: ApiStatus.error,
              ),
            );
          }
        }
      default:
    }
  }
  Future<void> _fetchDataIsolate(String request) async {
    final receivePort = ReceivePort();
    print('ApiManager._fetchDataIsolate');

    await Isolate.spawn(doTheFutureCall, [receivePort.sendPort, request]);

    // Receiving the result from the spawned isolate
    final result = await receivePort.first as String;
    print(result);
  }

  void doTheFutureCall(List<dynamic> args) async {
    final sendPort = args[0] as SendPort;
    final request = args[1] as String;
    print('ApiManager.doTheFutureCall');

    // Performing the operation
    final data = "$request Jasir";

    // Sending the result back to the main isolate
    sendPort.send(data);
  }

  void manageConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    setConnection(connectivityResult);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        await setConnection(result);
        final isConnected = await checkConnection();
        if (!isConnected) {
          return manageConnectivity();
        }
        for (var i = 0; i < _apiQueue.length; i++) {
          _requestController.add(_apiQueue[i]);
        }
      },
    );
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    } catch(e){
      return false;
    }
  }

  Future<void> setConnection(ConnectivityResult connectivityResult) async {
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        await setIsConnected();
        break;
      case ConnectivityResult.none:
      case ConnectivityResult.bluetooth:
      default:
        isConnected = false;
        break;
    }
  }

  Future<bool> setIsConnected() async {
    final connected = await checkConnection();
    isConnected = connected;
    if (!connected) await setIsConnected();
    return connected;
  }

  Stream<ApiResponse?> addNewRequest(ApiRequest request) {
    final responseController = StreamController<ApiResponse>.broadcast();
    request = request.setKey();
    _requestResponseMap[request] = responseController;
    _apiQueue.add(request);
    _nextApi();
    return responseController.stream;
  }

  _nextApi() {
    if (_apiQueue.isEmpty) return;
    try {
      for (var i = 0; i < _apiQueue.length; ++i) {
        var api = _apiQueue[i];
        if (api.status == ApiRequestStatus.pending) {
          _requestController.add(api);
          _apiQueue[i] = api.copyWith(status: ApiRequestStatus.calling);
          break;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  _removeCompleted(ApiRequest request) async {
    if (_apiQueue.isEmpty) return;
    final controller = _requestResponseMap[request];
    await controller?.close();
    _requestResponseMap.remove(request);
    _apiQueue.removeWhere((element) => element.id == request.id);
  }

  void close() {
    _requestController.close();
    _connectivitySubscription.cancel();
  }
}

class ApiRequest {
  final int? id;
  final String? url;
  final ApiType apiType;
  final Future Function()? customFutureOperation;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? headers;
  final ApiRequestStatus? status;

  ApiRequest({
    this.url,
    this.body,
    this.customFutureOperation,
    this.status = ApiRequestStatus.pending,
    this.apiType = ApiType.post,
    this.headers,
    this.id,
  });

  ApiRequest copyWith({ApiRequestStatus? status}) {
    return ApiRequest(
      status: status ?? this.status,
      customFutureOperation: customFutureOperation,
      apiType: apiType,
      headers: headers,
      body: body,
      url: url,
      id: id,
    );
  }

  ApiRequest setKey() {
    return ApiRequest(
      status: status,
      customFutureOperation: customFutureOperation,
      apiType: apiType,
      headers: headers,
      body: body,
      url: url,
      id: UniqueKey().hashCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "body": body,
      "customFutureOperation": customFutureOperation,
      "status": status,
      "apiType": apiType,
      "headers": headers,
      "id": id,
    };
  }

  Future<ApiResponse> get() async {
    try {
      final response = await http.get(Uri.parse(url ?? ""));
      final json = tryDecode(response.body);
      if (response.statusCode == 200 && json != null) {
        return ApiResponse(
          data: json,
          apiStatus: ApiStatus.success,
        );
      }
      return ApiResponse(
        apiStatus: ApiStatus.error,
        error: "Something went wrong",
      );
    } on TimeoutException catch (_) {
      return ApiResponse(
        apiStatus: ApiStatus.error,
        error: "Timeout!!, please try again later",
      );
    } on SocketException catch (_) {
      return ApiResponse(
        apiStatus: ApiStatus.notConnected,
        error: "Not Connected!, please connect to a network",
      );
    }
  }

  static dynamic tryDecode(data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    return other is ApiRequest && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ApiResponse {
  final dynamic data;
  final String? error;
  final ApiStatus? apiStatus;

  ApiResponse({
    this.data,
    this.error,
    this.apiStatus,
  });
}

enum ApiType {
  get,
  post,
  put,
  patch,
  custom,
}

enum ApiStatus {
  success,
  error,
  timeout,
  notConnected,
}

enum ApiRequestStatus {
  pending,
  calling,
  error,
  completed,
}