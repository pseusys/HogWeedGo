import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/views/photo_gallery.dart';
import 'package:client/misc/const.dart';
import 'package:client/blocs/view/view_bloc.dart';
import 'package:client/blocs/view/view_state.dart';
import 'package:client/models/report.dart';


class ReportView extends StatefulWidget {
  const ReportView({Key? key}): super(key: key);

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  Report? _report;

  @override
  void initState() {
    super.initState();
    _report = context.select((ViewBloc bloc) => bloc.state.current);
  }

  Widget _comment(String body, BuildContext context, { String username = "Anonymous", String? photoURL }) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              child: photoURL == null ? Text(username[0]) : Image.network(photoURL),
            ),
            const SizedBox(width: MARGIN),
            Column(
              children: [
                Text(username, style: Theme.of(context).textTheme.headline6),
                Text(body),
              ],
            ),
          ],
        ),
        const SizedBox(height: MARGIN),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ViewBloc, ViewState>(
      listener: (context, state) => setState(() => _report = state.current),
      child: DraggableScrollableSheet(
        expand: false,
        builder: (_, ScrollController scrollController) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: OFFSET),
            controller: scrollController,
            children: [
              const SizedBox(height: MARGIN),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_report!.type, style: Theme.of(context).textTheme.headline4),
                  Chip(
                    avatar: const CircleAvatar(
                      child: Text('ST'),
                    ),
                    label: Text(_report!.status.name),
                  ),
                ],
              ),
              const SizedBox(height: MARGIN),

              Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: MARGIN),
                  Column(
                    children: [
                      Text(_report!.address ?? "Place unknown", style: Theme.of(context).textTheme.headline6),
                      Text(_report!.place.toString()),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: MARGIN),

              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: MARGIN),
                  Text(_report!.date.toString(), style: Theme.of(context).textTheme.headline6),
                ],
              ),
              const SizedBox(height: MARGIN),

              PhotoGallery(false),
              const SizedBox(height: MARGIN),

              _comment(_report!.initComment, context, username: _report!.subs?.firstName ?? "Anonymous"),

              const Divider(
                thickness: 5,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: MARGIN),

              for (var comment in _report!.comments) _comment(comment.text, context, username: comment.subs?.firstName ?? "Anonymous"),

              const TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: 'Comment',
                ),
                textInputAction: TextInputAction.send,
                // TODO: send comment.
              ),
              const SizedBox(height: MARGIN),
            ],
          );
        },
      ),
    );
  }
}
