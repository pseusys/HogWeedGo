import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

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

  static const server = "example.com";
  static const route = "/";

  static final _location = Location();

  static void _askForLocation(BuildContext c) => ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
    content: Text("Location services will stay unavailable until location permission is not granted! :("),
  ));

  static Future<Location?> ensureLocation(BuildContext context) async {
    bool _service = await _location.serviceEnabled();
    if (!_service) {
      _service = await _location.requestService();
      if (!_service) {
        _askForLocation(context);
        return null;
      }
    }
    PermissionStatus _permission = await _location.hasPermission();
    if (_permission == PermissionStatus.denied || _permission == PermissionStatus.deniedForever) {
      _permission = await _location.requestPermission();
      if (_permission != PermissionStatus.granted) {
        _askForLocation(context);
        return null;
      }
    }
    return _location;
  }

  static Future<Location?> locationEnabled() async {
    final _service = await _location.serviceEnabled();
    final _permission = await _location.hasPermission();
    if (_service && ((_permission == PermissionStatus.denied) || (_permission == PermissionStatus.deniedForever))) {
      return _location;
    } else { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HogWeedGo',
      initialRoute: MapPage.route,
      theme: ThemeData(),

      routes: {
        route: (_) => const MapPage(),
        MapPage.route: (_) => const MapPage(),
        AccountPage.route: (_) => const AccountPage(),
        AboutPage.route: (_) => const AboutPage(),

        AuthPage.route: (_) => const AuthPage(),
      },

      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == FullscreenPage.route) {
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
