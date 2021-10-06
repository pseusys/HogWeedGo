import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'main_drawer.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  final String title = "Map View";
  static const String route = "/map";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _me;

  void _check_permissions() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue accessing the position and request users of the App to enable the location services.
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try requesting permissions again (this is also where Android's shouldShowRequestPermissionRationale returned true. According to Android guidelines your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can continue accessing the position of the device.
    });
  }

  @override
  void initState() {
    super.initState();
    Geolocator.getPositionStream().listen((Position? position) {
      print(position);
      if (position != null) {
        setState(() => _me = LatLng(position.latitude, position.longitude));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_me);
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),

        body: FlutterMap(
          options: MapOptions(
            center: LatLng(59.937500, 30.308611),
            zoom: 9.0,
            minZoom: 1.0
          ),

          layers: [
            TileLayerOptions(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
            ),
            MarkerLayerOptions(
              markers: [
                if (_me != null) Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _me!,
                    builder: (ctx) => const FlutterLogo()
                )
              ]
            )
          ]
        ),

        floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Increment',
            child: const Icon(Icons.add)
        ),

        drawer: const MainDrawer()
    );
  }
}
