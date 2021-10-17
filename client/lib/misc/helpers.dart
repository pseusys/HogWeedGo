import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';


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
