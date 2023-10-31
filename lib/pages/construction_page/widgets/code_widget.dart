import 'package:blog/helper/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlighting/flutter_highlighting.dart';
import 'package:flutter_highlighting/themes/github-dark.dart';
import 'package:highlighting/languages/dart.dart';

class CodeWidget extends StatelessWidget {
  const CodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const code = """import 'package:blog/widgets/hover_widget.dart';
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
}""";
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Write the Code content below",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          sbh(15),
          Container(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: context.w * 50,
                child: HighlightView(
                  code,
                  languageId: dart.id,
                  theme: githubDarkTheme,
                  padding: const EdgeInsets.all(12),
                  textStyle: const TextStyle(
                    fontFamily: 'My awesome monospace font',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
