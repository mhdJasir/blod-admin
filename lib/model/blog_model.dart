import 'package:blog/model/widget_model.dart';

class BlogModel {
  final String title;
  final String subTitle;
  final List<WidgetModel> widgets;

  BlogModel({
    required this.title,
    required this.subTitle,
    required this.widgets,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "sub_title": subTitle,
      "widgets": widgets.map((e) => e.toJson()).toList(),
    };
  }
}
