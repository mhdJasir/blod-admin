import 'package:blog/helper/api_manager.dart';
import 'package:blog/helper/constants.dart';
import 'package:flutter/material.dart';

import 'helper/api_call_helper.dart';

ValueNotifier<BuildContext?> appContext = ValueNotifier<BuildContext?>(null);

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
  void initState() {
    super.initState();
  }

  String? error;
  String? day;
  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            error != null
                ? Text(error!)
                : response?.data != null
                    ? (response?.data['data'] == null)
                        ? Text((response?.data['message'] ?? "").toString())
                        : ListView.builder(
                            itemCount: (response?.data['data'] ?? []).length,
                            shrinkWrap: true,
                            itemBuilder: (c, i) {
                              final map = (response?.data['data'] ?? [])[i];
                              return buildPlace(map);
                            },
                          )
                    : sbh(5),
            MaterialButton(
              onPressed: () async {
                final request = ApiRequest(
                  customFutureOperation: () => ApiCallHelper.getApi(
                    path:
                        "https://wordsapiv1.p.rapidapi.com/words/hatchback/typeOf",
                  ),
                );

                apiManager.addNewRequest(request).listen((event) {
                  if (event == null) return;
                  if (event.apiStatus == ApiStatus.error) {
                    error = event.error ?? "";
                    setState(() {});
                    return;
                  }
                  error = null;
                  response = event;
                  setState(() {});
                  return;
                });
              },
              height: 50,
              child: const Text("Start Call"),
            ),
            // response2?.data == null
            //     ? Container()
            //     : ListView.builder(
            //         itemCount: (response2?.data['data'] ?? []).length,
            //         shrinkWrap: true,
            //         itemBuilder: (c, i) {
            //           final map = (response2?.data['data'] ?? [])[i];
            //           return buildPlace(map);
            //         },
            //       ),
            sbh(100),
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