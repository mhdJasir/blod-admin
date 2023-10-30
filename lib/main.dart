import 'package:blog/bloc/blog_construct_bloc.dart';
import 'package:blog/bloc/theme_cubit.dart';
import 'package:blog/pages/construction_page/home_page.dart';
import 'package:blog/test_page.dart';
import 'package:blog/widgets/side_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    // redirect: (context, state) {
    //   if (!isFirstTime) return null;
    //   return "/login";
    // },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return SideNavWidget(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (c, state) => const HomePage()),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestPage(),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppTheme()),
        BlocProvider(create: (_) => BlogConstructBloc()),
      ],
      child: BlocBuilder<AppTheme, ThemeMode>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Blog-Admin',
            themeMode: state,
            debugShowCheckedModeBanner: false,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
            ),
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
