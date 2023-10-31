import 'package:blog/bloc/blog_construct_bloc.dart';
import 'package:blog/model/widget_model.dart';
import 'package:blog/pages/construction_page/widgets/image_widget.dart';
import 'package:blog/pages/construction_page/widgets/text_widget.dart';
import 'package:blog/pages/construction_page/widgets/widget_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WidgetsList extends StatelessWidget {
  const WidgetsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlogConstructBloc, BlogConstructState>(
      buildWhen: (oldState, state) => state is! NonUpdateChange,
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.widgets.length,
          shrinkWrap: true,
          padding: const EdgeInsets.only(right: 20),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (c, i) {
            final widgetModel = state.widgets[i];
            int controllerIndex = 0;
            for (int k = 0; k < i; k++) {
              if (state.widgets[k].type == WidgetType.text) controllerIndex++;
            }
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: WidgetWrapper(
                onClose: () {
                  context.read<BlogConstructBloc>().add(
                        WidgetRemoved(widget: widgetModel),
                      );
                },
                child: getWidget(
                  context,
                  widgetModel,
                  controller: widgetModel.type == WidgetType.text
                      ? state.controllers[controllerIndex]
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget getWidget(BuildContext context, WidgetModel widgetModel,
      {TextEditingController? controller}) {
    switch (widgetModel.type) {
      case WidgetType.text:
        return TextWidget(
          controller: controller!,
          onTapOutside: (val) {
            widgetModel = widgetModel.copyWith(properties: {
              "text": val,
            });
            context.read<BlogConstructBloc>().add(
                  WidgetChanged(widget: widgetModel),
                );
          },
        );
      case WidgetType.image:
        return const ImageWidget();
      case WidgetType.video:
      case WidgetType.code:
      case WidgetType.images:
      default:
        return Container();
    }
  }
}
