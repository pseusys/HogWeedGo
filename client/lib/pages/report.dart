import 'package:client/blocs/location/location_event.dart';
import 'package:client/blocs/report/report_bloc.dart';
import 'package:client/blocs/report/report_event.dart';
import 'package:client/blocs/report/report_state.dart';
import 'package:client/repositories/account_repository.dart';
import 'package:client/repositories/location_repository.dart';
import 'package:client/repositories/report_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:formz/formz.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/views/photo_gallery.dart';
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
  @override
  Widget build(BuildContext context) {
    final photoGallery = PhotoGallery(true);
    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(title: Text(widget.title)),

        body: BlocProvider(
          create: (_) => ReportBloc(ReportRepository(), context.read<AccountRepository>()),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: MARGIN, horizontal: OFFSET),
            children: [
              Text("Report!", style: Theme.of(context).textTheme.headline3),
              const SizedBox(height: MARGIN),

              Text("Initial comment", style: Theme.of(context).textTheme.headline5),
              _CommentInput(),
              const SizedBox(height: MARGIN),

              Text("Location", style: Theme.of(context).textTheme.headline5),
              _AddressInput(),
              const SizedBox(height: GAP),

              _Map(),
              const SizedBox(height: GAP),

              _LocationInput(),
              const SizedBox(height: MARGIN),

              Text("Photos", style: Theme.of(context).textTheme.headline5),
              photoGallery,
              const SizedBox(height: MARGIN),

              _SubmitButton()
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (previous, current) => previous.comment != current.comment,
      builder: (context, state) {
        return TextField(
          maxLines: 3,
          key: const Key('reportForm_commentInput_textField'),
          onChanged: (comment) => context.read<ReportBloc>().add(ReportCommentChanged(comment)),
          decoration: InputDecoration(
            hintText: "Description: a few words about the subject of your report: its size, color, etc.",
            errorText: state.comment.invalid ? 'Invalid initial comment' : null,
          ),
        );
      },
    );
  }
}

class _AddressInput extends StatelessWidget {
  final TextEditingController _addressController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final me = context.select((LocationBloc bloc) => bloc.state.me);
    if (me != null && _addressController.text == "") {
      // TODO: add nominatim container to server (authenticated use), add address to LocationRepository.
      context.read<LocationRepository>().getAddress(me).then((String? value) {
        if (value != null) {
          _addressController.text = value;
          context.read<ReportBloc>().add(ReportAddressChanged(value));
        }
      });
    }
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (previous, current) => previous.address != current.address,
      builder: (context, state) {
        return TextField(
          key: const Key('reportForm_addressInput_textField'),
          controller: _addressController,
          onChanged: (comment) => context.read<ReportBloc>().add(ReportAddressChanged(comment)),
          decoration: InputDecoration(
            hintText: "Address of tour report, how to get there, some visible landmarks, etc.",
            errorText: state.comment.invalid ? 'Invalid address' : null,
          ),
        );
      },
    );
  }
}

class _Map extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final me = context.select((LocationBloc bloc) => bloc.state.me);
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (previous, current) => previous.place != current.place,
      builder: (context, state) {
        return SizedBox(
          height: OFFSET * 5,
          child: FlutterMap(
            options: MapOptions(
              center: me ?? STP,
              zoom: me == null ? 10.0 : 14.0,
              minZoom: 10.0,
              interactiveFlags: InteractiveFlag.drag | InteractiveFlag.flingAnimation | InteractiveFlag.doubleTapZoom,
              onTap: (_, LatLng point) => context.read<ReportBloc>().add(ReportPlaceChanged(point)),
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
                  Marker(width: MARKER, height: MARKER, point: me ?? STP, builder: (c) => const FlutterLogo())
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (previous, current) => previous.place != current.place,
      builder: (context, state) {
        return OutlinedButton(
          key: const Key('reportForm_locationInput_button'),
          onPressed: () async {
            context.read<LocationBloc>().add(const EnsureLocation());
            final me = context.select((LocationBloc bloc) => bloc.state.me);
            context.read<ReportBloc>().add(ReportPlaceChanged(me!));
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
        );
      }
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress ? const CircularProgressIndicator() : ElevatedButton(
          key: const Key('reportForm_submit_button'),
          child: const Text('Submit'),
          onPressed: state.status.isValidated ? () => context.read<ReportBloc>().add(const ReportSubmitted()) : null,
        );
      },
    );
  }
}
