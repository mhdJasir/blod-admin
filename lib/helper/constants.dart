import 'dart:convert';

import 'package:flutter/material.dart';

extension ContextExtensionss on BuildContext {
  double get notificationAreaHeight => MediaQuery.of(this).padding.top;

  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  double get h => MediaQuery.of(this).size.height / 100;

  double get w => MediaQuery.of(this).size.width / 100;

  double get textScaleFactor => MediaQuery.of(this).textScaleFactor;

  void pop([dynamic value]) => Navigator.pop(this, value);
}

extension StringExtension on Object? {
  void get prettyPrint {
    if (this == null) {
      debugPrint("Got Null");
      return;
    }
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(this);
    debugPrint(prettyprint);
  }
}

extension LogAll on dynamic {
  void log() => debugPrint(toString());
}

Widget sbh(double height) => SizedBox(height: height);

Widget sbw(double width) => SizedBox(width: width);

void unFocus() => FocusManager.instance.primaryFocus?.unfocus();