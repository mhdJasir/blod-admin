import 'package:flutter/material.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MaterialButton(
            color: Colors.green,
            child: const Text(
              "Click Me",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
