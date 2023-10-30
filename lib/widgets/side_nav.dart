import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool isFirstTime = true;

class SideNavWidget extends StatefulWidget {
  const SideNavWidget({super.key, required this.child});

  final Widget child;

  @override
  State<SideNavWidget> createState() => _SideNavWidgetState();
}

class _SideNavWidgetState extends State<SideNavWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blueGrey,
              child: Column(
                children: [
                  titleWidget("First", () {
                    GoRouter.of(context).go('/');
                  }),
                  titleWidget("Second", () {
                    GoRouter.of(context).go('/second');
                  }),
                  titleWidget("Third", () {
                    GoRouter.of(context).go('/third');
                  }),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget titleWidget(String title, VoidCallback ontap) {
    return InkWell(
      onTap: ontap,
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
