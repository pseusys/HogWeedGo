import 'package:flutter/material.dart';

import 'package:client/navigate/fast_route.dart';
import 'package:client/pages/about.dart';
import 'package:client/pages/fullscreen.dart';
import 'package:client/pages/map.dart';
import 'package:client/pages/account.dart';
import 'package:client/pages/auth.dart';
import 'package:client/pages/none.dart';
import 'package:client/pages/report.dart';
import 'package:client/misc/utils.dart';
import 'package:client/dialogs/auth_dialog.dart';


class HogWeedGo extends StatelessWidget {
  HogWeedGo({Key? key}) : super(key: key);

  final navigatorKey = GlobalKey<NavigatorState>();

  static final server = const String.fromEnvironment("SERVER", defaultValue: "https://localhost").urize();
  static const route = "/";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HogWeedGo',
      navigatorKey: navigatorKey,

      initialRoute: MapPage.route,
      theme: ThemeData(),

      // TODO: fix back pressing -> migrate to navigator 2.0
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == route) {
          return FastRoute((_) => const NonePage(), settings);

        } else if (settings.name == MapPage.route) {
          return FastRoute((_) => const MapPage(), settings);

        } else if (settings.name == AccountPage.route) {
          return FastRoute((_) => const AccountPage(), settings);

        } else if (settings.name == AboutPage.route) {
          return FastRoute((_) => const AboutPage(), settings);

        } else if (settings.name == AuthPage.route) {
          return FastRoute((_) => const AuthPage(), settings);

        } else if (settings.name == FullscreenPage.route) {
          final args = settings.arguments as List<Object>;
          return MaterialPageRoute(builder: (_) => FullscreenPage(args[0] as String, args[1] as bool), fullscreenDialog: true);

        } else if (settings.name == ReportPage.route) {
          return MaterialPageRoute(builder: (_) => const ReportPage(), fullscreenDialog: true);

        } else if (settings.name == AuthDialog.route) {
          return DialogRoute(context: navigatorKey.currentState!.overlay!.context, builder: (_) => const AuthDialog(), settings: settings);

        } else {
          return MaterialPageRoute(builder: (_) => const NonePage());
        }
      },
    );
  }
}
