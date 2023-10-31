part of 'blog_construct_bloc.dart';

@immutable
abstract class BlogConstructState {
  final List<WidgetModel> widgets;
  final List<TextEditingController> controllers;
  const BlogConstructState({required this.widgets,required this.controllers});
}

class BlogConstructInitial extends BlogConstructState {
  const BlogConstructInitial({required super.widgets, required super.controllers});
}

class BlogContentChanged extends BlogConstructState {
  const BlogContentChanged({required super.widgets, required super.controllers});
}

class NonUpdateChange extends BlogConstructState {
  const NonUpdateChange({required super.widgets, required super.controllers});
}
