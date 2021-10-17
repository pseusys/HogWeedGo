import 'dart:async';

import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';


extension NavigatorStateExtension on NavigatorState {
  void popAllAndPushNamed(String routeName, {Object? arguments}) {
    popUntil(ModalRoute.withName(Navigator.defaultRouteName));
    pushNamed(routeName, arguments: arguments);
  }
}

extension _LatLongExtension on LocationData {
  LatLng? getLatLng() => ((latitude != null) && (longitude != null)) ? LatLng(latitude!, longitude!) : null;
}

extension LatLongExtension on Location {
  Future<LatLng?> getLatLng() async => (await getLocation()).getLatLng();
  Stream<LatLng?> getLatLngStream() => onLocationChanged.map((LocationData ld) => ld.getLatLng());
}
