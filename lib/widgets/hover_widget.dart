import 'package:flutter/cupertino.dart';

class HoverWidget extends StatefulWidget {
  const HoverWidget({
    super.key,
    required this.builder,
  });

  final Widget Function(bool isHovering) builder;

  @override
  State<HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => onHover(true),
      onExit: (event) => onHover(false),
      child: widget.builder(isHovering),
    );
  }

  void onHover(bool isHover) {
    isHovering = isHover;
    setState(() {});
  }
}
