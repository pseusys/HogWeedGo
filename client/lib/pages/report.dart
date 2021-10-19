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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),

      body: Container(
        margin: const EdgeInsets.all(MARGIN),
        child: Form(
          child: ListView(
            padding: const EdgeInsets.all(MARGIN),
            children: [
              const Text("Report!"),

              const Text("What have you found?"),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(hintText: "Description: a few words about the subject of your report: its size, color, etc."),
                onSaved: (String? value) => description = value ?? "",
              ),

              const Text("Location"),
              TextFormField(
                decoration: const InputDecoration(hintText: "Address of tour report, how to get there, some visible landmarks, etc."),
                controller: _addressController,
                onSaved: (String? value) => location = value ?? "",
              ),
              SizedBox(
                height: OFFSET * 5,
                child: FlutterMap(
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
              ElevatedButton(
                  onPressed: () => setState(() { if (widget._me != null) _me = widget._me; }),
                  child: Row(
                    children: const [
                      Text('Use my location'),
                      SizedBox(height: GAP),
                      Icon(Icons.gps_fixed),
                    ],
                  )
              ),


            ],
          ),
        ),
      ),
    );
  }
}
