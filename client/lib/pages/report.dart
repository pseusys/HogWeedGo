import 'package:client/blocs/location/location_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/views/photo_gallery.dart';
import 'package:client/misc/access.dart';
import 'package:client/misc/const.dart';
import 'package:client/misc/cached_provider.dart';
import 'package:client/blocs/location/location_bloc.dart';


class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}): super(key: key);

  final String title = "Report";
  static const String route = "/report";

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late LatLng? me;
  late LatLng? current;

  var description = "";
  var location = "";
  var comment = "";
  var date = DateTime.now();
  var time = TimeOfDay.now();

  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    me = context.select((LocationBloc bloc) => bloc.state.me);
    if (me != null && _addressController.text == "") {
      getAddress(me!).then((String? value) => setState(() {
        if (value != null) _addressController.text = value;
      }));
    }
    current = me;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(3000),
    );
    if (picked != null) {
      setState(() { date = picked; });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (picked != null) {
      setState(() { time = picked; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoGallery = PhotoGallery(true);
    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(title: Text(widget.title)),

        body: Form(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: MARGIN, horizontal: OFFSET),
            children: [
              Text("Report!", style: Theme.of(context).textTheme.headline3),
              const SizedBox(height: MARGIN),

              Text("What have you found?", style: Theme.of(context).textTheme.headline5),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(hintText: "Description: a few words about the subject of your report: its size, color, etc."),
                onSaved: (String? value) => description = value ?? "",
              ),
              const SizedBox(height: MARGIN),

              Text("Location", style: Theme.of(context).textTheme.headline5),
              TextFormField(
                decoration: const InputDecoration(hintText: "Address of tour report, how to get there, some visible landmarks, etc."),
                controller: _addressController,
                onSaved: (String? value) => location = value ?? "",
              ),
              const SizedBox(height: GAP),
              SizedBox(
                height: OFFSET * 5,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: current ?? STP,
                    zoom: current == null ? 10.0 : 14.0,
                    minZoom: 10.0,
                    interactiveFlags: InteractiveFlag.drag | InteractiveFlag.flingAnimation | InteractiveFlag.doubleTapZoom,
                    onTap: (_, LatLng point) => setState(() => current = point),
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
                        Marker(width: MARKER, height: MARKER, point: current ?? STP, builder: (c) => const FlutterLogo())
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GAP),
              OutlinedButton(
                onPressed: () async {
                  context.read<LocationBloc>().add(const EnsureLocation());
                  setState(() {
                    if (me != null) {
                      current = me;
                      _mapController.move(current!, _mapController.zoom);
                    }
                  });
                },
                child: Row(
                  children: const [
                    Text("Use my location"),
                    SizedBox(width: GAP),
                    Icon(Icons.gps_fixed),
                  ],
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Theme.of(context).textTheme.bodyText1?.color),
                ),
              ),
              const SizedBox(height: MARGIN),

              Text("Photos", style: Theme.of(context).textTheme.headline5),
              photoGallery,
              const SizedBox(height: MARGIN),

              Text("Date and Time", style: Theme.of(context).textTheme.headline5),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _selectDate(context),
                    tooltip: "Select date",
                    icon: const Icon(Icons.calendar_today),
                  ),
                  const SizedBox(width: GAP),
                  IconButton(
                    onPressed: () => _selectTime(context),
                    tooltip: "Select time",
                    icon: const Icon(Icons.access_time),
                  ),
                  const SizedBox(width: MARGIN),
                  Text("${date.year}-${date.month}-${date.day} ${time.hour}:${time.minute}")
                ],
              ),
              const SizedBox(height: MARGIN),

              Text("Initial comment", style: Theme.of(context).textTheme.headline5),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(hintText: "Initial comment: what else do you want to add to your report?"),
                onSaved: (String? value) => comment = value ?? "",
              ),
              const SizedBox(height: MARGIN),

              ElevatedButton(
                onPressed: () {},
                child: const Text("Send!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
