import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  ApiManager() {
    manageConnectivity();
    _requestController.stream.listen(
      (event) async {
        switch (event.apiType) {
          case ApiType.get:
            final response = await event.get();
            final responseController = _requestResponseMap[event];
            if (responseController != null) {
              if (response.apiStatus != ApiStatus.notConnected) {
                _removeCompleted(event);
                responseController.add(response);
              }
            }
          case ApiType.custom:
            if (event.customFutureOperation == null) break;
            final data = await event.customFutureOperation;
            final responseController = _requestResponseMap[event];
            if (responseController != null) {
              if (data.apiStatus != ApiStatus.notConnected) {
                _removeCompleted(event);
                responseController.add(ApiResponse(data: data));
              }
            }
          default:
        }
      },
    );
  }

  final _requestController = StreamController<ApiRequest>();
  final _requestResponseMap = <ApiRequest, StreamController<ApiResponse>>{};
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final List<ApiRequest> _apiQueue = <ApiRequest>[];
  final _connectivity = Connectivity();
  bool isConnected = false;

  void manageConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    setConnection(connectivityResult);
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        setConnection(result);
        await Future.delayed(const Duration(milliseconds: 100));
        if (isConnected) {
          for (var i = 0; i < _apiQueue.length; i++) {
            _requestController.add(_apiQueue.elementAt(i));
          }
        }
      },
    );
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
    _requestResponseMap[request] = responseController;
    _apiQueue.add(request);
    request.setKey();
    _nextApi();
    return responseController.stream;
  }

  _nextApi() {
    if (_apiQueue.isEmpty) return;
    try {
      for (var i = 0; i < _apiQueue.toList().length; ++i) {
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

  _removeCompleted(ApiRequest request) {
    if (_apiQueue.isEmpty) return;
    _apiQueue.removeWhere((element) => element.url == request.url);
  }

  void close() {
    _requestController.close();
    _requestController.close();
    _connectivitySubscription.cancel();
  }
}

typedef FutureCallback = Future<dynamic> Function();

class ApiRequest {
  final int? id;
  final String? url;
  final ApiType apiType;
  final Future? customFutureOperation;
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
