import 'package:blog/helper/constants.dart';
import 'package:blog/model/widget_model.dart';
import 'package:blog/pages/construction_page/widgets/image_widget.dart';
import 'package:blog/pages/construction_page/widgets/text_widget.dart';
import 'package:blog/pages/construction_page/widgets/widget_wrapper.dart';
import 'package:blog/widgets/animated_underline.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<TextEditingController> controllers = [];
  List<WidgetModel> widgets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Construct the Blog here",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700, fontSize: 35),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: const AnimatedUnderLine(),
              ),
              sbh(20),
              Row(
                children: [
                  const Text("Enter a Title for the Blog"),
                  sbw(15),
                  const Expanded(
                    child: TextField(),
                  ),
                ],
              ),
              sbh(20),
              ListView.builder(
                itemCount: widgets.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(right: 20),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (c, i) {
                  final widgetModel = widgets[i];
                  int controllerIndex = 0;
                  for (int k = 0; k < i; k++) {
                    if (widgets[k].type == WidgetType.text) {
                      controllerIndex++;
                    }
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: WidgetWrapper(
                      onClose: () {
                        int controllerIndex = -1;
                        for (int k = 0; k < widgets.length; k++) {
                          final current = widgets[k];
                          if (current.type == WidgetType.text) controllerIndex++;
                          if (current.id == widgetModel.id) {
                            widgets.removeAt(k);
                            if (current.type == WidgetType.text) {
                              controllers.removeAt(controllerIndex);
                            }
                            break;
                          }
                        }
                        setState(() {});
                      },
                      child: getWidget(
                        context,
                        widgetModel,
                        controller: widgetModel.type == WidgetType.text
                            ? controllers[controllerIndex]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: PopupMenuButton<WidgetType>(
          onSelected: (val) {
            widgets.add(
              WidgetModel(
                id: widgets.length + 1,
                type: val,
                properties: {},
              ),
            );
            if (val == WidgetType.text) {
              controllers.add(TextEditingController());
            }
            setState(() {});
          },
          itemBuilder: (c) {
            return WidgetType.values
                .map(
                  (e) => PopupMenuItem<WidgetType>(
                    value: e,
                    child: Text(e.name),
                  ),
                )
                .toList();
          },
          child: const SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Icon(Icons.add),
          ),
        ),
      ),
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
