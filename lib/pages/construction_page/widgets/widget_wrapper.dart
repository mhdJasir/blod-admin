import 'package:blog/widgets/hover_widget.dart';
import 'package:flutter/material.dart';

class WidgetWrapper extends StatelessWidget {
  const WidgetWrapper({super.key, required this.child, this.onClose});

  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return HoverWidget(
      builder: (isHovering) {
        return Container(
          decoration: BoxDecoration(
            border: isHovering
                ? Border.all(
                    color: Theme.of(context).textTheme.titleLarge?.color ??
                        Colors.white,
                  )
                : null,
            borderRadius: isHovering ? BorderRadius.circular(10) : null,
          ),
          child: Stack(
            children: [
              child,
              Visibility(
                visible: isHovering,
                child: Positioned(
                  top: 3,
                  right: 3,
                  child: InkWell(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}