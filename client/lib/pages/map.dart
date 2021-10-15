import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/views/main_drawer.dart';
import 'package:client/pages/report.dart';
import 'package:client/views/report_view.dart';
import 'package:client/misc/const.dart';

const marker = picture * 2/3;


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  final title = "Map View";
  static const route = "/map";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _me;
  set me (Position? p) { if (p != null) setState(() => _me = LatLng(p.latitude, p.longitude)); }

  late final StreamSubscription _meStream;

  @override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition().then((value) => me = value).catchError((e) => print("No location provided!"));
    _meStream = Geolocator.getPositionStream().listen((Position? p) => me = p)
      ..onError((e) => print("No location received!"));
  }

  @override
  void dispose() {
    _meStream.cancel();
    super.dispose();
  }

  Marker _generateMarker(BuildContext context) => Marker(
      width: marker,
      height: marker,
      point: LatLng(59.937500, 30.308611),
      builder: (ctx) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) => const ReportView(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  isScrollControlled: true
              ),
              child: const FlutterLogo(textColor: Colors.green)
          )
      )
  );

  Scaffold _showMap(BuildContext context) {
    return Scaffold(
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
                    _generateMarker(context),

                    if (_me != null) Marker(
                        width: marker,
                        height: marker,
                        point: _me!,
                        builder: (ctx) => const FlutterLogo()
                    )
                  ]
              )
            ]
        ),

        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(ReportPage.route),
            tooltip: "Report!",
            child: const Icon(Icons.add)
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),

        body: Navigator(
            onGenerateRoute: (RouteSettings s) => MaterialPageRoute(builder: (BuildContext c) => _showMap(c), settings: s)
        ),

        drawer: const MainDrawer()
    );
  }
}
