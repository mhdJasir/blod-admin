import 'dart:io';

import 'package:blog/helper/constants.dart';
import 'package:blog/helper/image_helper.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  File? pickedImage;

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
              final image = await ImageHelper.instance.pickImageFromGallery();
              if (image == null) return;
              pickedImage = image;
              setState(() {});
            },
            child: Container(
              width: context.w * 100,
              height: context.h * 60,
              decoration: BoxDecoration(border: Border.all()),
              child: pickedImage != null
                  ? Image.network(
                      pickedImage!.path,
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
