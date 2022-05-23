import 'package:latlong2/latlong.dart';


class LocationState {
  LatLng? me;
  String? address;

  LocationState(this.me, this.address);

  LocationState setMe(LatLng? current) => LocationState(current, address);

  LocationState setAddress(String? current) => LocationState(me, current);
}
