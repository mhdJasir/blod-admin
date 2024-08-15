import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

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
    final responseController = _requestResponseMap[request];
    if (responseController != null && !responseController.isClosed) {
      try {
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

  int _recursiveCount = 0;

  Future<void> onConnectionActive() async {
    if (!isConnected || (_recursiveCount == 10)) return;
    _recursiveCount += 1;
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
      if (hasAccess) return true;
      return false;
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

  void cancelRequest(ApiRequest request) {
    _apiQueue.remove(request);
    final controller = _requestResponseMap[request];
    controller?.close();
    _requestResponseMap.remove(request);
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