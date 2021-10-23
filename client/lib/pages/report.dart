import 'package:client/views/photo_gallery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/misc/helpers.dart';
import 'package:client/misc/const.dart';


class ReportPage extends StatefulWidget {
  const ReportPage(this._me, {Key? key}): super(key: key);

  final LatLng? _me;
  final String title = "Report";
  static const String route = "/report";

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  LatLng? _me;

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
    _me = widget._me;
    if (_me != null) {
      getAddress(_me!).then((String? value) => setState(() {
        if ((value != null) && (_addressController.text == "")) { _addressController.text = value; }
      }));
    }
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
    return Scaffold(
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
                  center: _me ?? STP,
                  zoom: _me == null ? 10.0 : 14.0,
                  minZoom: 10.0,
                  onTap: (_, LatLng point) => setState(() => _me = point),
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                    subdomains: ["a", "b"],
                    attributionBuilder: (_) => const Text("© Humanitarian OSM Team"),
                  ),
                  MarkerLayerOptions(
                    markers: [
                      Marker(width: MARKER, height: MARKER, point: _me ?? STP, builder: (c) => const FlutterLogo())
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GAP),
            OutlinedButton(
              onPressed: () => setState(() {
                if (widget._me != null) {
                  _me = widget._me;
                  _mapController.move(_me!, _mapController.zoom);
                }
              }),
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
            const PhotoGallery(true),
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
              onPressed: () {
                //TODO: send report!
              },
              child: const Text("Send!"),
            ),
          ],
        ),
      ),
    );
  }
}
