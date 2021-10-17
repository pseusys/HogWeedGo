import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';


extension NavigatorStateExtension on NavigatorState {
  void popAllAndPushNamed(String routeName, {Object? arguments}) {
    popUntil(ModalRoute.withName(Navigator.defaultRouteName));
    pushNamed(routeName, arguments: arguments);
  }
}

extension LatLongExtension on LocationData {
  LatLng? getLatLng() => ((latitude != null) && (longitude != null)) ? LatLng(latitude!, longitude!) : null;
}
