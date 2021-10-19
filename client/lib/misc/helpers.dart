import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';


void _askForLocation(BuildContext c) => ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
  content: Text("Location services will stay unavailable until location permission is not granted! :("),
));

Future<Location?> ensureLocation(BuildContext context) async {
  Location location = Location();
  bool service = await location.serviceEnabled();
  if (!service) {
    service = await location.requestService();
    if (!service) {
      _askForLocation(context);
      return null;
    }
  }
  PermissionStatus permission = await location.hasPermission();
  if (permission == PermissionStatus.denied || permission == PermissionStatus.deniedForever) {
    permission = await location.requestPermission();
    if (permission != PermissionStatus.granted) {
      _askForLocation(context);
      return null;
    }
  }
  return location;
}

Future<Location?> locationEnabled() async {
  Location location = Location();
  final service = await location.serviceEnabled();
  final permission = await location.hasPermission();
  if (service && ((permission == PermissionStatus.granted) || (permission == PermissionStatus.grantedLimited))) {
    return location;
  } else { return null; }
}


Future<String?> getAddress(LatLng point) async {
  final response = await get(
    Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json'),
    headers: kIsWeb ? {} : {'User-Agent': 'HogWeedGo'},
  );
  if (response.statusCode != 200) return null;

  final address = jsonDecode(response.body)['address'];
  final houseNumber = address["house_number"] != null ? ", ${address["house_number"]}" : null;
  final houseName = address["house_name"] != null ? ", ${address["house_name"]}" : null;
  final result = "${address["road"] ?? ""}${houseNumber ?? ""}${houseName ?? ""}";
  return result != "" ? "$result (by OSM Nominatim)" : null;
}
