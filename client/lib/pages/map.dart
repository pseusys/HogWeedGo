import 'dart:async';

import 'package:client/main.dart';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/views/main_drawer.dart';
import 'package:client/pages/report.dart';
import 'package:client/views/report_view.dart';
import 'package:client/misc/const.dart';
import 'package:client/misc/extensions.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  final title = "Map View";
  static const route = "/map";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _me;
  late final StreamSubscription? _meStream;

  @override
  void initState() {
    super.initState();
    print("object0");
    HogWeedGo.locationEnabled().then((Location? loc) {
      print("object1");
      loc?.getLatLng().then((LatLng? l) => setState(() { print("object2"); if (l != null) _me = l; }));
      _meStream = loc?.getLatLngStream().listen((LatLng? l) => setState(() { if (l != null) _me = l; }));
    });
  }

  @override
  void dispose() {
    _meStream?.cancel();
    super.dispose();
  }

  Marker _generateMarker(BuildContext context) => Marker(
    width: MARKER,
    height: MARKER,
    point: STP,
    builder: (ctx) => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) => const ReportView(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          isScrollControlled: true,
        ),
        child: const FlutterLogo(textColor: Colors.green),
      ),
    ),
  );

  Scaffold _showMap(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(center: LatLng(59.937500, 30.308611), zoom: 9.0, minZoom: 1.0),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
            subdomains: ["a", "b"],
            attributionBuilder: (_) => const Text("© Humanitarian OSM Team"),
          ),
          MarkerLayerOptions(
            markers: [
              _generateMarker(context),
              if (_me != null) Marker(width: MARKER, height: MARKER, point: _me!, builder: (c) => const FlutterLogo()),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(ReportPage.route, arguments: _me),
        tooltip: "Report!",
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: do once!
    HogWeedGo.ensureLocation(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),

      body: Navigator(
        onGenerateRoute: (RouteSettings s) => MaterialPageRoute(builder: (BuildContext c) => _showMap(c), settings: s),
      ),

      drawer: const MainDrawer(),
    );
  }
}
