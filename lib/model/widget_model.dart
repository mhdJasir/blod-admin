class WidgetModel {
  final int id;
  final WidgetType type;
  final Map<String, dynamic> properties;

  WidgetModel({required this.id, required this.type, required this.properties});

  WidgetModel copyWith({WidgetType? type, Map<String, dynamic>? properties}) {
    return WidgetModel(
      id: id,
      type: type ?? this.type,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.name,
      "properties": properties,
    };
  }

  WidgetType? getType(val) => WidgetType.values
      .where((element) => element.name == val)
      .toList()
      .firstOrNull;
}

enum WidgetType {
  text,
  video,
  code,
  image,
  images,
}
