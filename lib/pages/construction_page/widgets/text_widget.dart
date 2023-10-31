import 'package:blog/helper/constants.dart';
import 'package:blog/widgets/dropdown_button_widget.dart';
import 'package:blog/widgets/field.dart';
import 'package:flutter/material.dart';

class TextWidget extends StatefulWidget {
  const TextWidget(
      {super.key, required this.onTapOutside, required this.controller});

  final Function(String,String) onTapOutside;
  final TextEditingController controller;

  @override
  State<TextWidget> createState() => _TextWidgetState();
}

class _TextWidgetState extends State<TextWidget> {
  String selectedStyle = "h1";

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
          Row(
            children: [
              Expanded(
                child: Field(
                  controller: widget.controller,
                  onTapOutside: (val) {
                    if (val == null) return;
                    widget.onTapOutside.call(val,selectedStyle);
                  },
                  maxLines: null,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                ),
              ),
              sbw(15),
              Text("Size"),
              sbw(5),
              SizedBox(
                width: 70,
                child: DropDownWidget(
                  items: const ["h1","subtitle", "h2", "h3", "h4","content"],
                  value: selectedStyle,
                  onSelected: (val) {
                    selectedStyle = val;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
