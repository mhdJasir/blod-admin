import 'package:blog/helper/api_call_helper.dart';
import 'package:blog/helper/api_manager.dart';
import 'package:flutter/material.dart';

class ApiTest extends StatefulWidget {
  const ApiTest({super.key});

  @override
  State<ApiTest> createState() => _ApiTestState();
}

class _ApiTestState extends State<ApiTest> {
  ApiResponse? response;
  ApiResponse? response2;
  final apiManager = ApiManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              (response?.data ?? "").toString(),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            MaterialButton(
              onPressed: () async {
                final request = ApiRequest(
                  // url: "http://3.27.134.239:3000/api/getCategories",
                  apiType: ApiType.custom,
                  customFutureOperation: ApiCallHelper.getApi(
                    path: "http://3.27.134.239:3000/api/getCategories",
                  ),
                );
                final request2 = ApiRequest(
                  url: "http://3.27.134.239:3000/api/getDistricts",
                  apiType: ApiType.get,
                );
                apiManager.addNewRequest(request).listen((event) {
                  if (event != null) {
                    response = event;
                    setState(() {});
                  }
                });
                apiManager.addNewRequest(request2).listen((event) {
                  if (event != null) {
                    response2 = event;
                    setState(() {});
                  }
                });
              },
              height: 50,
              child: const Text("Start Call"),
            ),
            Text(
              (response2?.data ?? "").toString(),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
