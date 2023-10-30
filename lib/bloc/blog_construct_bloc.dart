import 'package:bloc/bloc.dart';
import 'package:blog/model/widget_model.dart';
import 'package:flutter/material.dart' show TextEditingController;
import 'package:meta/meta.dart';

part 'blog_construct_event.dart';

part 'blog_construct_state.dart';

class BlogConstructBloc extends Bloc<BlogConstructEvent, BlogConstructState> {
  BlogConstructBloc()
      : super(const BlogConstructInitial(widgets: [], controllers: [])) {
    on<WidgetAdded>((event, emit) => addNewWidget(event, emit));
    on<WidgetChanged>((event, emit) => updateWidget(event, emit));
    on<WidgetRemoved>((event, emit) => removeWidget(event, emit));
  }

  addNewWidget(WidgetAdded event, Emitter<BlogConstructState> emit) {
    final list = [...state.widgets, event.widget];
    List<TextEditingController> controllers = state.controllers;
    if (event.widget.type == WidgetType.text) {
      controllers = [...controllers, TextEditingController()];
    }
    emit(BlogContentChanged(widgets: list, controllers: controllers));
  }

  Future<void> removeWidget(
      WidgetRemoved event, Emitter<BlogConstructState> emit) async {
    int controllerIndex = -1;
    for (int k = 0; k < state.widgets.length; k++) {
      final widget = state.widgets[k];
      if (widget.type == WidgetType.text) controllerIndex++;
      if (widget.id == event.widget.id) {
        await Future.microtask(() {
          state.widgets.removeAt(k);
          if (widget.type == WidgetType.text) {
            state.controllers.removeAt(controllerIndex);
          }
        });
        print('List count : ${state.widgets.length}');
        emit(state);
        break;
      }
    }
  }

  updateWidget(WidgetChanged event, Emitter<BlogConstructState> emit) {
    final list = state.widgets.map((element) {
      if (element.id == event.widget.id) return event.widget;
      return element;
    }).toList();
    emit(
      BlogContentChanged(
        widgets: list,
        controllers: state.controllers,
      ),
    );
  }

  int getId() {
    return state.widgets.length + 1;
  }
}
