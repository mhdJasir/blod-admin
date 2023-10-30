import 'package:blog/helper/constants.dart';
import 'package:blog/widgets/field.dart';
import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key, required this.onTapOutside, required this.controller});

  final Function(String) onTapOutside;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Write the text content below",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          sbh(15),
          Field(
            controller: controller,
            onTapOutside: (val) {
              if (val == null) return;
              onTapOutside.call(val);
            },
            maxLines: null,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          ),
        ],
      ),
    );
  }
}
