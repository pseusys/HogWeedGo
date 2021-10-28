import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';


void _askForLocation(BuildContext c, bool serviceUnavailable) {
  const service = "Location services will stay unavailable until GPS is not enabled :(";
  const permission = "Location services will stay unavailable until location permission is not granted! :(";
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(
    content: Text(serviceUnavailable ? service : permission),
    action: SnackBarAction(
      label: 'Enable!',
      onPressed: () {
        // TODO: call support if called once.
        if (kIsWeb) {
          launch("https://docs.buddypunch.com/en/articles/919258-how-to-enable-location-services-for-chrome-safari-edge-and-android-ios-devices-gps-setting");
        } else if (Theme.of(c).platform == TargetPlatform.iOS) {
          launch(serviceUnavailable ? "https://support.google.com/accounts/answer/6179507?hl=en&ref_topic=7189122" : "https://support.google.com/accounts/answer/6179507?hl=en&ref_topic=7189122");
        } else if (Theme.of(c).platform == TargetPlatform.android) {
          launch("https://support.apple.com/en-us/HT207092");
        }
      },
    ),
  ));
}

Future<Location?> ensureLocation(BuildContext context) async {
  Location location = Location();
  bool service = await location.serviceEnabled();
  if (!service) {
    service = await location.requestService();
    if (!service) {
      _askForLocation(context, true);
      return null;
    }
  }
  PermissionStatus permission = await location.hasPermission();
  if (permission == PermissionStatus.denied || permission == PermissionStatus.deniedForever) {
    permission = await location.requestPermission();
    if (permission != PermissionStatus.granted) {
      _askForLocation(context, false);
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



void retainFocus(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) { currentFocus.unfocus(); }
}
