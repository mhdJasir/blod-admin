part of 'blog_construct_bloc.dart';

@immutable
abstract class BlogConstructEvent {}

class WidgetAdded extends BlogConstructEvent {
  final WidgetModel widget;

  WidgetAdded({required this.widget});
}

class WidgetRemoved extends BlogConstructEvent {
  final WidgetModel widget;

  WidgetRemoved({required this.widget});
}

class WidgetChanged extends BlogConstructEvent {
  final WidgetModel widget;

  WidgetChanged({required this.widget});
}
