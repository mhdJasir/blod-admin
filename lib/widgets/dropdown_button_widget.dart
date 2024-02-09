import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DropDownWidget<T> extends StatefulWidget {
  final List<T> items;
  final String? hint;
  final double? height;
  final T? value;
  final bool isEnabled;
  final bool isNormalIcon;
  final Color? iconBgColor;
  final bool redBorder;
  final Border? border;
  final T? typeInstance;
  final String Function(T)? dropDownVal;
  final Widget? lastItem;
  final TextStyle? hintStyle;
  final VoidCallback? onClickLastItem;
  final Function(T) onSelected;

  const DropDownWidget({
    Key? key,
    required this.items,
    this.hint,
    this.isNormalIcon = false,
    required this.onSelected,
    this.height = 24,
    this.value,
    this.redBorder = false,
    this.isEnabled = true,
    this.lastItem,
    this.iconBgColor,
    this.hintStyle,
    this.border,
    this.onClickLastItem,
    this.dropDownVal,
    this.typeInstance,
  }) : super(key: key);

  @override
  DropDownButtonCustom2State<T> createState() =>
      DropDownButtonCustom2State<T>();
}

class DropDownButtonCustom2State<T> extends State<DropDownWidget<T>> {

  @override
  Widget build(BuildContext context) {
    final length = widget.items.length + (widget.lastItem != null ? 1 : 0);
    return IgnorePointer(
      ignoring: !widget.isEnabled,
      child: SizedBox(
        height: widget.height ?? 50,
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: widget.hint == null
                ? null
                : Text(
                    widget.hint!,
                    style: widget.hintStyle ??
                        TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.withOpacity(0.9),
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
            items: List.generate(
              length,
              (index) {
                if (index == widget.items.length && widget.lastItem != null) {
                  return DropdownMenuItem(
                    value: widget.typeInstance,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onClickLastItem?.call();
                      },
                      child: widget.lastItem!,
                    ),
                  );
                }
                T item = widget.items[index];
                return DropdownMenuItem<T>(
                  value: widget.items[index],
                  child: Text(
                    widget.dropDownVal != null
                        ? widget.dropDownVal!(item)
                        : item.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
            value: widget.value,
            onChanged: (value) {
              if (value != null) {
                widget.onSelected(value);
              }
            },
            buttonStyleData: ButtonStyleData(
              height: 100,
              padding: const EdgeInsets.only(left: 5, right: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: widget.redBorder
                    ? Border.all(
                        color: Colors.red,
                      )
                    : widget.border ??
                        Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
              ),
              elevation: 0,
            ),
            iconStyleData: widget.isNormalIcon
                ? const IconStyleData(
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                    ),
                  )
                : IconStyleData(
                    icon: Container(
                      height: widget.height,
                      width: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(2),
                            bottomRight: Radius.circular(2)),
                        color:
                            widget.iconBgColor ?? Colors.grey.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        size: 14,
                      ),
                    ),
                    iconEnabledColor: Colors.black,
                    iconDisabledColor: Colors.grey,
                  ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              elevation: 0,
              offset: const Offset(0, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(6),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 25,
              padding: EdgeInsets.only(left: 8, right: 0),
            ),
          ),
        ),
      ),
    );
  }
}
