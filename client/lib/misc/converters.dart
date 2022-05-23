import 'package:latlong2/latlong.dart';


Uri uriFromString(String uri) => Uri.parse(uri);

Uri? uriFromStringNull(String? uri) => uri != null ? uriFromString(uri) : null;

LatLng latLngFromObject(Map<String, dynamic> obj) => LatLng(obj['lat'] as double, obj['lng'] as double);

Map<String, dynamic> latLngToObject(LatLng latlng) => { 'lat': latlng.latitude, 'lng': latlng.longitude };

DateTime dateTimeFromNumber(int dateTime) => DateTime.fromMillisecondsSinceEpoch(dateTime);

toNull(_) => null;
