import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ApiManager {
  int maxConcurrentRequests = 10;

  ApiManager() {
    manageConnectivity();
    _requestController.stream.listen(onNewRequest);
  }

  final _requestController = StreamController<ApiRequest>();
  final _requestResponseMap = <ApiRequest, StreamController<ApiResponse>>{};
  final List<ApiRequest> _apiQueue = <ApiRequest>[];
  final Map<int, Completer<void>> _completerMap = {};
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final _connectivity = Connectivity();
  bool isConnected = false;

  Future<void> onNewRequest(ApiRequest request) async {
    final responseController = _requestResponseMap[request];
    final requestCompleter = _completerMap[request.id];
    if (responseController != null && !responseController.isClosed) {
      try {
        if (requestCompleter!.isCompleted) {
          responseController.add(
            ApiResponse(
              apiStatus: ApiStatus.error,
              error: "Request Cancelled",
            ),
          );
          _removeCompleted(request);
          return;
        }
        final data = await request.customFutureOperation!.call();
        responseController.add(
          ApiResponse(
            data: data,
            apiStatus: ApiStatus.success,
          ),
        );
        _removeCompleted(request);
      } catch (e) {
        responseController.add(
          ApiResponse(
            data: e,
            error: e.toString(),
            apiStatus: ApiStatus.error,
          ),
        );
      }
    }
  }

  void manageConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    setConnection(connectivityResult);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        log(result.name);
        setConnection(result);
        onConnectionActive();
      },
    );
  }

  int _recursiveCall = 0;

  Future<void> onConnectionActive() async {
    if (!isConnected || (_recursiveCall == 10)) return;
    _recursiveCall += 1;
    final haveInternet = await checkConnection();
    if (!haveInternet) return onConnectionActive();
    for (var i = 0; i < _apiQueue.length; i++) {
      _requestController.add(_apiQueue[i]);
    }
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final hasAccess = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      return hasAccess;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  void setConnection(ConnectivityResult connectivityResult) {
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        isConnected = true;
        break;
      case ConnectivityResult.none:
      case ConnectivityResult.bluetooth:
      default:
        isConnected = false;
        break;
    }
  }

  Stream<ApiResponse?> addNewRequest(ApiRequest request) {
    final responseController = StreamController<ApiResponse>.broadcast();
    request = request.setKey();
    _completerMap[request.id!] = Completer<void>();
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
      log(e.toString());
    }
  }

  _removeCompleted(ApiRequest request) async {
    if (_apiQueue.isEmpty) return;
    final controller = _requestResponseMap[request];
    await controller?.close();
    _requestResponseMap.remove(request);
    _completerMap.remove(request.id);
    _apiQueue.removeWhere((element) => element.id == request.id);
  }

  void cancelRequest(ApiRequest request) {
    final requestCompleter = _completerMap[request.id];
    if (requestCompleter != null && !requestCompleter.isCompleted) {
      requestCompleter.completeError("Request Cancelled");
      _completerMap.remove(request.id);
      _apiQueue.remove(request);
      final controller = _requestResponseMap[request];
      controller?.close();
      _requestResponseMap.remove(request);
    }
  }

  void close() {
    _requestController.close();
    _connectivitySubscription.cancel();
  }
}

class ApiRequest {
  final int? id;
  final Future Function()? customFutureOperation;
  final ApiRequestStatus? status;

  ApiRequest({
    this.customFutureOperation,
    this.status = ApiRequestStatus.pending,
    this.id,
  });

  ApiRequest copyWith({ApiRequestStatus? status}) {
    return ApiRequest(
      status: status ?? this.status,
      customFutureOperation: customFutureOperation,
      id: id,
    );
  }

  ApiRequest setKey() {
    return ApiRequest(
      status: status,
      customFutureOperation: customFutureOperation,
      id: UniqueKey().hashCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "customFutureOperation": customFutureOperation,
      "status": status,
      "id": id,
    };
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