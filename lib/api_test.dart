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
            response?.data == null
                ? Container()
                : ListView.builder(
                    itemCount: (response?.data['data'] ?? []).length,
                    shrinkWrap: true,
                    itemBuilder: (c, i) {
                      final map = (response?.data['data'] ?? [])[i];
                      return buildPlace(map);
                    },
                  ),
            MaterialButton(
              onPressed: () async {
                final request = ApiRequest(
                  apiType: ApiType.custom,
                  customFutureOperation: ApiCallHelper.getApi(
                    path: "http://3.27.134.239:3000/api/getDistricts",
                  ),
                );
                final request2 = ApiRequest(
                  apiType: ApiType.custom,
                  customFutureOperation: ApiCallHelper.getApi(
                    path: "http://3.27.134.239:3000/api/getCategories",
                  ),
                );
                apiManager.addNewRequest(request).listen((event) {
                  if (event != null) {
                    response = event;
                    setState(() {});
                  }
                });
                // apiManager.addNewRequest(request2).listen((event) {
                //   if (event != null) {
                //     response2 = event;
                //     setState(() {});
                //   }
                // });
              },
              height: 50,
              child: const Text("Start Call"),
            ),
            response2?.data == null
                ? Container()
                : ListView.builder(
                    itemCount: (response2?.data['data'] ?? []).length,
                    shrinkWrap: true,
                    itemBuilder: (c, i) {
                      final map = (response2?.data['data'] ?? [])[i];
                      return buildPlace(map);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildPlace(Map<String, dynamic> map) {
    return Column(
      children: [
        Text(
          map['name'],
          style: const TextStyle(
            fontSize: 20,
            color: Colors.green,
          ),
        ),
        Image.network(
          map['image'],
          height: 200,
          width: 200,
        ),
      ],
    );
  }
}
