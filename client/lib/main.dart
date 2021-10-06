import 'package:flutter/material.dart';

import 'about_page.dart';
import 'map_page.dart';
import 'settings_page.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        initialRoute: MapPage.route,
        theme: ThemeData(primarySwatch: Colors.blue),
        routes: {
          MapPage.route: (context) => const MapPage(),
          SettingsPage.route: (context) => const SettingsPage(),
          AboutPage.route: (context) => const AboutPage()
        }
    );
  }
}
