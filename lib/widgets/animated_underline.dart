import 'package:flutter/material.dart';

class AnimatedUnderLine extends StatefulWidget {
  const AnimatedUnderLine({super.key});

  @override
  State<AnimatedUnderLine> createState() => _AnimatedUnderLineState();
}

class _AnimatedUnderLineState extends State<AnimatedUnderLine>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInCubic,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
        const Duration(milliseconds: 300), () => controller.forward());
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: animation.value * constraints.maxWidth,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.blueGrey,
              ),
            );
          },
        );
      },
    );
  }
}
