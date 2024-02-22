import 'package:blog/bloc/blog_construct_bloc.dart';
import 'package:blog/helper/constants.dart';
import 'package:blog/model/widget_model.dart';
import 'package:blog/pages/construction_page/widgets/widgets_list.dart';
import 'package:blog/widgets/animated_underline.dart';
import 'package:blog/work_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              // Text(
              //   "Construct the Blog here",
              //   style: Theme.of(context)
              //       .textTheme
              //       .titleLarge
              //       ?.copyWith(fontWeight: FontWeight.w700, fontSize: 35),
              // ),
              // Container(
              //   margin: const EdgeInsets.symmetric(vertical: 5),
              //   child: const AnimatedUnderLine(),
              // ),
              // sbh(20),
              // Row(
              //   children: [
              //     const Text("Enter a Title for the Blog"),
              //     sbw(15),
              //     const Expanded(
              //       child: TextField(),
              //     ),
              //   ],
              // ),
              // sbh(20),
              // const WidgetsList(),
              WorkPage(),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: null,
      //   child: PopupMenuButton<WidgetType>(
      //     onSelected: (val) {
      //       context.read<BlogConstructBloc>().add(
      //             WidgetAdded(
      //               widget: WidgetModel(
      //                 id: context.read<BlogConstructBloc>().getId(),
      //                 type: val,
      //                 properties: {},
      //               ),
      //             ),
      //           );
      //     },
      //     itemBuilder: (c) {
      //       return WidgetType.values
      //           .map(
      //             (e) => PopupMenuItem<WidgetType>(
      //               value: e,
      //               child: Text(e.name),
      //             ),
      //           )
      //           .toList();
      //     },
      //     child: const SizedBox(
      //       height: double.infinity,
      //       width: double.infinity,
      //       child: Icon(Icons.add),
      //     ),
      //   ),
      // ),
    );
  }
}
