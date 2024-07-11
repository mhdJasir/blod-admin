import 'package:blog/api_test.dart';
import 'package:flutter/material.dart';

class CustomToast {
  CustomToast._({
    this.height = 60,
    this.width = 150,
    this.borderRadius,
    this.context,
    required this.type,
  });

  factory CustomToast.success(
      {double? height,
      double? width,
      double? borderRadius,
      BuildContext? context}) {
    return CustomToast._(
      height: height ?? 60,
      width: width ?? 150,
      context: context,
      type: ToastType.success,
      borderRadius: borderRadius,
    );
  }

  factory CustomToast.warning(
      {double? height,
      double? width,
      double? borderRadius,
      BuildContext? context}) {
    return CustomToast._(
      height: height ?? 60,
      width: width ?? 150,
      context: context,
      type: ToastType.warning,
      borderRadius: borderRadius,
    );
  }

  factory CustomToast.error(
      {double? height,
      double? width,
      double? borderRadius,
      BuildContext? context}) {
    return CustomToast._(
      height: height ?? 60,
      width: width ?? 150,
      context: context,
      type: ToastType.error,
      borderRadius: borderRadius,
    );
  }

  final double? height;
  final double? width;
  final double? borderRadius;
  final BuildContext? context;
  final ToastType type;
  final _overlayEntries = <OverlayEntry>[];

  BuildContext? get ctx => appContext.value;

  show(String msg) async {
    closeAllOverlays();
    if (ctx == null && context == null) return;
    final entry = overlayWidget(msg);
    _overlayEntries.add(entry);
    Overlay.of(context ?? ctx!).insert(entry);
  }

  OverlayEntry overlayWidget(String msg) {
    return OverlayEntry(
      opaque: false,
      builder: (c) {
        return ToastPage(
          msg: msg,
          type: type,
          closeOverlay: () {
            closeAllOverlays();
          },
        );
      },
    );
  }

  void closeAllOverlays() {
    for (var entry in _overlayEntries) {
      entry.remove();
    }
    _overlayEntries.clear();
  }
}

enum ToastType {
  success,
  warning,
  error,
}

class ToastPage extends StatefulWidget {
  const ToastPage({
    super.key,
    required this.closeOverlay,
    required this.msg,
    required this.type,
  });

  final Function closeOverlay;
  final String msg;
  final ToastType type;

  @override
  State<ToastPage> createState() => _ToastPageState();
}

class _ToastPageState extends State<ToastPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    super.initState();
    startAnimation();
  }

  Future<void> startAnimation() async {
    _controller.forward();
    await Future.delayed(const Duration(seconds: 3));
    _controller.reverse();
    widget.closeOverlay();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = 80;
    double width = 250;
    double padding = 10;
    double br = 5;
    final totalWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: totalWidth,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                right: _animation.value * totalWidth * 0.08,
                bottom: padding,
                child: FadeTransition(
                  opacity: _animation,
                  child: Material(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(br),
                        color: getBgColor(),
                      ),
                      alignment: Alignment.bottomRight,
                      height: height,
                      width: width,
                      child: Row(
                        children: [
                          Container(
                            height: double.infinity,
                            width: 5,
                            decoration: BoxDecoration(
                                color: getMsgColor(),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(br),
                                  bottomLeft: Radius.circular(br),
                                )),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                widget.msg,
                                style: TextStyle(
                                  color: getMsgColor(),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => widget.closeOverlay(),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color getBgColor() {
    switch (widget.type) {
      case ToastType.success:
        return Colors.green.shade100;
      case ToastType.warning:
        return Colors.yellow.shade100;
      case ToastType.error:
        return Colors.red.shade100;
    }
  }

  Color getMsgColor() {
    switch (widget.type) {
      case ToastType.warning:
        return Colors.yellow;
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
    }
  }
}
