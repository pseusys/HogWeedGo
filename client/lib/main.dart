import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';

import 'package:client/navigate/fast_route.dart';
import 'package:client/pages/about.dart';
import 'package:client/pages/fullscreen.dart';
import 'package:client/pages/map.dart';
import 'package:client/pages/account.dart';
import 'package:client/pages/auth.dart';
import 'package:client/pages/none.dart';
import 'package:client/pages/report.dart';


void main() => runApp(const HogWeedGo());

class HogWeedGo extends StatelessWidget {
  const HogWeedGo({Key? key}) : super(key: key);

  static const server = String.fromEnvironment("SERVER", defaultValue: "https://localhost");
  static const route = "/";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HogWeedGo',

      initialRoute: MapPage.route,
      theme: ThemeData(),

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
          var link = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => FullscreenPage(link), fullscreenDialog: true);

        } else if (settings.name == ReportPage.route) {
          var me = settings.arguments as LatLng?;
          return MaterialPageRoute(builder: (_) => ReportPage(me), fullscreenDialog: true);

        } else { return MaterialPageRoute(builder: (_) => const NonePage()); }
      },
    );
  }
}
