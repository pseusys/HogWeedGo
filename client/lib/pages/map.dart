import 'dart:async';

import 'package:client/blocs/reports/reports_bloc.dart';
import 'package:client/blocs/reports/reports_event.dart';
import 'package:client/blocs/reports/reports_state.dart';
import 'package:client/models/report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/views/main_drawer.dart';
import 'package:client/pages/report.dart';
import 'package:client/views/report_view.dart';
import 'package:client/misc/const.dart';
import 'package:client/access/location.dart';
import 'package:client/misc/cached_provider.dart';
import 'package:client/blocs/account/account_bloc.dart';
import 'package:client/dialogs/auth_dialog.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  final title = "Map View";
  static const route = "/map";

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _me;
  StreamSubscription? _meStream;

  Future _setupStream() async {
    final loc = await ensureLocation(context);
    _me = _me ?? LatLng(0, 0);

    final l = await loc?.getLocation();
    setState(() {
      _me!.latitude = l?.latitude ?? _me!.latitude;
      _me!.longitude = l?.longitude ?? _me!.longitude;
    });

    _meStream = loc?.onLocationChanged.handleError((dynamic err) {
      _meStream?.cancel();
      _meStream = null;
    }).listen((LocationData l) {
      if (mounted) {
        setState(() {
          _me!.latitude = l.latitude ?? _me!.latitude;
          _me!.longitude = l.longitude ?? _me!.longitude;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _setupStream();
    context.read<ReportsBloc>().add(const ReportsRequested());
  }

  @override
  void dispose() {
    _meStream?.cancel();
    _meStream = null;
    super.dispose();
  }

  Marker _generateMarker(BuildContext context, Report report) => Marker(
    width: MARKER,
    height: MARKER,
    point: report.place,
    builder: (ctx) => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const ReportView(),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(GAP)),
          ),
        ),
        child: const FlutterLogo(textColor: Colors.green),
      ),
    ),
  );

  Widget _showMap(BuildContext context) {
    var reports = [];
    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        reports = state.reports;
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: FlutterMap(
            options: MapOptions(
              center: STP,
              zoom: 9.0,
              minZoom: 1.0,
              interactiveFlags: InteractiveFlag.drag | InteractiveFlag.flingAnimation | InteractiveFlag.doubleTapZoom,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                subdomains: ["a", "b"],
                attributionBuilder: (_) => const Text("© Humanitarian OSM Team"),
                tileProvider: const CachedTileProvider(),
              ),
              MarkerLayerOptions(
                markers: [
                  for (var report in reports) _generateMarker(context, report),
                  if (_me != null) Marker(width: MARKER, height: MARKER, point: _me!, builder: (c) => const FlutterLogo()),
                ],
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final auth = context.select((AccountBloc bloc) => bloc.state.status);
              if (auth) {
                Navigator.of(context, rootNavigator: true).pushNamed(ReportPage.route, arguments: _me);
              } else {
                Navigator.of(context, rootNavigator: true).pushNamed(AuthDialog.route);
              }
              },
            tooltip: "Report!",
            child: const Icon(Icons.add),
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(title: Text(widget.title)),

        body: Navigator(
          onGenerateRoute: (RouteSettings s) => MaterialPageRoute(builder: (BuildContext c) => _showMap(c), settings: s),
        ),

        drawer: const MainDrawer(),
      ),
    );
  }
}
