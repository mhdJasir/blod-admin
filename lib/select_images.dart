import 'dart:typed_data';
import 'package:blog/helper/constants.dart';
import 'package:blog/helper/file_helper.dart';
import 'package:blog/image_network/image_network.dart';
import 'package:blog/image_network/web/box_fit_web.dart';
import 'package:blog/widgets/hover_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectImages extends StatefulWidget {
  const SelectImages({
    Key? key,
    this.onPicked,
    this.images,
  }) : super(key: key);
  final void Function(List<ImageData> images)? onPicked;
  final List<String>? images;

  @override
  State<SelectImages> createState() => _SelectImagesState();
}

class _SelectImagesState extends State<SelectImages> {
  bool isHovering = false;
  final offset = Offset.zero;
  List<ImageData> images = [];

  @override
  Widget build(BuildContext context) {
    const double font = 12;
    return Container(
      height: 200,
      width: 500,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3), color: Colors.white),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: images.isNotEmpty
                        ? Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: constraints.maxHeight * 0.8,
                                  child: ListView.separated(
                                    itemCount: images.length,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    scrollDirection: Axis.horizontal,
                                    separatorBuilder: (c, i) => sbw(5),
                                    itemBuilder: (c, i) {
                                      final image = images[i];
                                      return imageWidget(image, constraints, i);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : (widget.images != null && widget.images!.isNotEmpty)
                            ? Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: constraints.maxHeight * 0.8,
                                      child: ListView.separated(
                                        itemCount: (widget.images ?? []).length,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        scrollDirection: Axis.horizontal,
                                        separatorBuilder: (c, i) => sbw(5),
                                        itemBuilder: (c, i) {
                                          final image =
                                              (widget.images ?? [])[i];
                                          return webImageWidget(
                                            image,
                                            constraints,
                                            i,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  sbw(20),

                                sbw(20),
                              ],
                            ),
                );
              },
            ),
          ),
          Container(
            height: 35,
            width: 500,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(3),
                bottomLeft: Radius.circular(3),
              ),
              border: Border.all(
                  color: isHovering ? Colors.red : Colors.transparent,
                  width: isHovering ? 2 : 0),
              color: Colors.grey,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: "DRAG",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: font,
                    ),
                    children: [
                      const TextSpan(
                        text: " images here or ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: font,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: "Browse",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final List<ImageData> data =
                                await FileHelper().pickFilesAsBytes();
                            images.addAll(data);
                            setState(() {});
                            widget.onPicked?.call(images);
                          },
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: font,
                        ),
                      ),
                      const TextSpan(
                        text: " to upload",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: font,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    images.clear();
                    setState(() {});
                  },
                  child: const Text(
                    "CLEAR",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: font,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget imageWidget(ImageData image, BoxConstraints constraints, int i) {
    return HoverWidget(
      builder: (isHovering) {
        return Stack(
          children: [
            Container(
              width: 150,
              height: constraints.maxHeight * 0.9,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()..scale(isHovering ? 1.4 : 1),
                transformAlignment: Alignment.center,
                child: ClipRRect(
                  child: Image.memory(
                    Uint8List.fromList(image.bytes),
                    width: 150,
                    height: constraints.maxHeight * 0.9,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isHovering && i != 0,
              child: Positioned(
                top: 5,
                left: 5,
                child: InkWell(
                  onTap: () {
                    final temp = images[0];
                    images[0] = image;
                    images[i] = temp;
                    setState(() {});
                  },
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red,
                      size: 10,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isHovering,
              child: Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: () {
                    images.removeAt(i);
                    setState(() {});
                  },
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red.shade500,
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget webImageWidget(String image, BoxConstraints constraints, int i) {
    return HoverWidget(
      builder: (isHovering) {
        return Container(
          width: 150,
          height: constraints.maxHeight * 0.9,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(isHovering ? 1.4 : 1),
            transformAlignment: Alignment.center,
            child: ClipRRect(
              child: ImageNetworkLocal(
                image: image,
                width: 150,
                height: constraints.maxHeight * 0.9,
                fitWeb: BoxFitWeb.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget infoWidget(String image, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          image,
          color: Colors.grey.shade500,
          width: 80,
        ),
        sbh(10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}