import 'package:latlong2/latlong.dart';


class LocationState {
  LatLng? me;
  String? address;

  LocationState(this.me, this.address);

  LocationState setMe(LatLng? current) {
    me = current;
    return this;
  }

  LocationState setAddress(String? current) {
    address = current;
    return this;
  }
}
