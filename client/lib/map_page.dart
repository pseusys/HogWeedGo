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

  void _setMe(Position? p) => setState(() { _me = p != null ? LatLng(p.latitude, p.longitude) : null; });

  @override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition().then((value) => _setMe(value)).catchError((e) => print("No location provided!"));
    Geolocator.getPositionStream().listen((Position? p) => _setMe(p)).onError((e) => print("No location provided!"));
  }

  @override
  Widget build(BuildContext context) {
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
