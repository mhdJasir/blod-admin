import 'dart:isolate';
import 'dart:ui';

import 'package:blog/helper/api_call_helper.dart';
import 'package:blog/helper/api_manager.dart';
import 'package:blog/widgets/overlay_drop_down.dart';
import 'package:flutter/material.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      appContext.value = context;
    });
  }

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
            // response?.data == null
            //     ? Container()
            //     // : ListView.builder(
            //     //     itemCount: (response?.data['data'] ?? []).length,
            //     //     shrinkWrap: true,
            //     //     itemBuilder: (c, i) {
            //     //       final map = (response?.data['data'] ?? [])[i];
            //     //       return buildPlace(map);
            //     //     },
            //     //   ),
            //     : Text(response!.data.toString()),
            // MaterialButton(
            //   onPressed: () async {
            //     final request = ApiRequest(
            //       apiType: ApiType.custom,
            //       customFutureOperation: () => ApiCallHelper.getApi(
            //         path:
            //             "https://wordsapiv1.p.rapidapi.com/words/hatchback/typeOf",
            //       ),
            //     );
            //
            //     apiManager.addNewRequest(request).listen((event) {
            //       if (event != null) {
            //         response = event;
            //         setState(() {});
            //       }
            //     });
            //   },
            //   height: 50,
            //   child: const Text("Start Call"),
            // ),
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
            SizedBox(
              width: 200,
              child: OverlayDropdown(
                onChange: (val, index) {
                  day = val;
                  setState(() {});
                },
                items: days
                    .map((e) => DropdownItem(value: e, child: Text(e)))
                    .toList(),
              ),
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
