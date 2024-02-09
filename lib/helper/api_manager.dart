import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  ApiManager() {
    manageConnectivity();
    _requestController.stream.listen((event) async {
      print(event.apiType);
      switch (event.apiType) {
        case ApiType.get:
          final response = await event.get();
          if (response.apiStatus != ApiStatus.notConnected) {
            _removeCompleted(event);
            _responseController.add(response);
          }
        case ApiType.custom:
          print('ApiManager.ApiManager 1');
          if (event.customFutureOperation == null) break;
          print('ApiManager.ApiManager');
          final data = await event.customFutureOperation!!();
          print('api call');
          print(data);
          _removeCompleted(event);
          print('1');
          _responseController.add(ApiResponse(data: data));
          print('2');
        default:
      }
    });
  }

  final _requestController = StreamController<ApiRequest>();
  final _responseController = StreamController<ApiResponse>.broadcast();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final _apiQueue = Queue<ApiRequest>();
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
    _apiQueue.add(request);
    _nextApi();
    return _responseController.stream;
  }

  _nextApi() {
    if (_apiQueue.isEmpty) return;
    try {
      final request = _apiQueue.first;
      _requestController.add(request);
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

class ApiRequest {
  final String? url;
  final ApiType apiType;
  final FutureOr? customFutureOperation;
  final Map<String, dynamic>? body;
  final Map<String, dynamic>? headers;

  ApiRequest({
    this.url,
    this.body,
    this.customFutureOperation,
    this.apiType = ApiType.post,
    this.headers,
  });

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
