import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';


class LocationRepository {
  LatLng? _prev;

  Stream<LatLng?> get location async* {
    Location? loc = await ensureLocation();
    if (loc == null) yield null;
    //TODO: fix yields.

    final l = await loc!.getLocation();
    if (l.latitude != null && l.longitude != null) _prev = LatLng(l.latitude!, l.longitude!);
    yield _prev;

    yield* loc.onLocationChanged.map((LocationData l) {
      if (l.latitude != null && l.longitude != null) _prev = LatLng(l.latitude!, l.longitude!);
      return _prev;
    });
  }

  void _askForLocation(bool serviceUnavailable) {
    const service = "Location services will stay unavailable until GPS is not enabled :(";
    const permission = "Location services will stay unavailable until location permission is not granted! :(";
    // TODO: call support if called once.
    Fluttertoast.showToast(msg: serviceUnavailable ? service : permission);
  }

  Future<Location?> ensureLocation() async {
    Location location = Location();
    bool service = await location.serviceEnabled();
    if (!service) {
      service = await location.requestService();
      if (!service) {
        _askForLocation(true);
        return null;
      }
    }
    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied || permission == PermissionStatus.deniedForever) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        _askForLocation(false);
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
    } else {
      return null;
    }
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
}
