import 'package:latlong2/latlong.dart';


abstract class LocationEvent {
  const LocationEvent();
}

class LocationChanged extends LocationEvent {
  final LatLng? current;
  const LocationChanged(this.current);
}

class EnsureLocation extends LocationEvent {
  const EnsureLocation();
}

class GetAddress extends LocationEvent {
  final String? address;
  const GetAddress(this.address);
}
