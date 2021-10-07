import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'about_page.dart';
import 'map_page.dart';
import 'account_page.dart';
import 'report_page.dart';


void _check_permissions() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue accessing the position and request users of the App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try requesting permissions again (this is also where Android's shouldShowRequestPermissionRationale returned true. According to Android guidelines your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can continue accessing the position of the device.
}

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
          AccountPage.route: (context) => const AccountPage(),
          AboutPage.route: (context) => const AboutPage(),

          ReportPage.route: (context) => const ReportPage()
        }
    );
  }
}
