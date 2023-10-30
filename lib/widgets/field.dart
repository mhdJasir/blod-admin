import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Field extends StatelessWidget {
  const Field({
    Key? key,
    this.controller,
    this.radius,
    this.borderColor,
    this.fillColor,
    this.isNumberInput = false,
    this.readOnly = false,
    this.hint,
    this.hintStyle,
    this.prefixIcon,
    this.onChanged,
    this.autofillHints,
    this.maxLines = 1,
    this.textCapitalization,
    this.textInputType,
    this.onTapOutside,
    this.inputFormatters = const [],
    this.suffixIcon,
    this.obscureText = false,
    this.expands = false,
    this.style,
    this.suffixText,
    this.contentPadding,
    this.onSubmitted,
  }) : super(key: key);
  final TextEditingController? controller;
  final double? radius;
  final Color? borderColor;
  final Color? fillColor;
  final String? hint;
  final TextStyle? hintStyle;
  final int? maxLines;
  final TextStyle? style;
  final Widget? prefixIcon;
  final EdgeInsets? contentPadding;
  final TextCapitalization? textCapitalization;
  final TextInputType? textInputType;
  final Widget? suffixIcon;
  final bool isNumberInput;
  final String? autofillHints;
  final bool readOnly;
  final bool expands;
  final bool obscureText;
  final String? suffixText;
  final List<TextInputFormatter> inputFormatters;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSubmitted;
  final void Function(String?)? onTapOutside;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTapOutside: (val){
        onTapOutside?.call(controller?.text);
      },
      onSubmitted: (val) {
        onSubmitted?.call(val);
      },
      textAlignVertical: TextAlignVertical.top,
      maxLines: maxLines,
      expands: expands,
      keyboardType: isNumberInput
          ? TextInputType.number
          : textInputType ?? TextInputType.text,
      readOnly: readOnly,
      autofillHints: autofillHints == null ? null : [autofillHints!],
      inputFormatters: isNumberInput
          ? [
              ...inputFormatters,
              FilteringTextInputFormatter.digitsOnly,
            ]
          : [...inputFormatters],
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      obscureText: obscureText,
      style: style,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffixText,
        hintStyle:
            hintStyle?.copyWith(color: hintStyle?.color?.withOpacity(0.6)),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: border,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        errorBorder: border,
        focusedErrorBorder: border,
        enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      ),
    );
  }

  OutlineInputBorder get border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius ?? 3),
        borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
      );
}
