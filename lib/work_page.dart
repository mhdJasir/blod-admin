import 'package:blog/helper/constants.dart';
import 'package:blog/helper/file_helper.dart';
import 'package:blog/select_images.dart';
import 'package:blog/widgets/hover_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  bool isHovering = false;
  late DropzoneViewController _controller;
  Uint8List? file;
  ImageData? imageData;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SelectImages(
          //   onPicked: (images) {
          //     if (images.isEmpty) return;
          //     imageData = images.first;
          //     setState(() {});
          //   },
          // ),
          // Container(
          //   width: 150,
          //   height: 200,
          //   clipBehavior: Clip.antiAlias,
          //   decoration: const BoxDecoration(),
          //   child: AnimatedContainer(
          //     duration: const Duration(milliseconds: 200),
          //     curve: Curves.easeInOut,
          //     transform: Matrix4.identity()..scale(isHovering ? 1.4 : 1),
          //     transformAlignment: Alignment.center,
          //     child: ClipRRect(
          //       child: Image.memory(
          //         Uint8List.fromList(bytes),
          //         width: 150,
          //         height: 200,
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          // ),
          sbh(100),
          // imageData!=null?
          // HoverWidget(builder: (isHovering) {
          //   return AnimatedContainer(
          //     transform: Matrix4.identity()..scale(isHovering ? 1.2 : 1),
          //     duration: const Duration(milliseconds: 800),
          //     curve: Curves.easeInOut,
          //     transformAlignment: Alignment.center,
          //     child: Image.memory(
          //       Uint8List.fromList(imageData!.bytes),
          //       width: 300,
          //     ),
          //   );
          // }):Container(),
          Container(
            height: 100,
            width: 200,
            color: isHovering ? Colors.green.shade400 : Colors.white,
            child: Stack(
              children: [
                DropzoneView(
                  onCreated: (controller) {
                    _controller = controller;
                    setState(() {});
                  },
                  onHover: () {
                    isHovering = true;
                    setState(() {});
                  },
                  onLeave: () {
                    isHovering = true;
                    setState(() {});
                  },
                  onDrop: (val) async {
                    file = await _controller.getFileData(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          file != null
              ? HoverWidget(builder: (isHovering) {
                  return AnimatedContainer(
                    transform: Matrix4.identity()..scale(isHovering ? 1.2 : 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    transformAlignment: Alignment.center,
                    child: Image.memory(
                      file!,
                      width: 300,
                    ),
                  );
                })
              : Container(),
          sbh(10),
          MaterialButton(
            color: Colors.green,
            child: const Text(
              "Upload",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              final files=await _controller.pickFiles(multiple: true);
              print(files[0]);
              file= await _controller.getFileData(files[0]);
              setState(() {});
            },
          ),
          sbh(20),

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
