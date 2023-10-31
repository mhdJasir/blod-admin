import 'dart:typed_data';

import 'package:blog/helper/constants.dart';
import 'package:blog/helper/image_helper.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key, this.onPicked});

  final Function(ImageData)? onPicked;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  ImageData? pickedImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pick an Image",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          sbh(15),
          InkWell(
            onTap: () async {
              pickedImage = await ImageHelper.instance.pickAFileAsBytes();
              setState(() {});
              if (pickedImage != null) widget.onPicked?.call(pickedImage!);
            },
            child: Container(
              width: context.w * 100,
              height: context.h * 60,
              decoration: BoxDecoration(border: Border.all()),
              child: pickedImage != null
                  ? Image.memory(
                      Uint8List.fromList(pickedImage!.bytes),
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.image),
            ),
          ),
        ],
      ),
    );
  }
}
