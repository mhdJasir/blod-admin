import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppTheme extends Cubit<ThemeMode> {
  AppTheme() : super(ThemeMode.dark);

  switchTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }
}
