import 'package:flutter/material.dart';

import 'package:client/views/photo_gallery.dart';
import 'package:client/misc/const.dart';


class ReportView extends StatelessWidget {
  const ReportView({Key? key}): super(key: key);

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
    return DraggableScrollableSheet(
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
                Text('type', style: Theme.of(context).textTheme.headline4),
                const Chip(
                  avatar: CircleAvatar(
                    child: Text('ST'),
                  ),
                  label: Text('status'),
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
                    Text('address', style: Theme.of(context).textTheme.headline6),
                    const Text('coords'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: MARGIN),

            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: MARGIN),
                Text('time', style: Theme.of(context).textTheme.headline6),
              ],
            ),
            const SizedBox(height: MARGIN),

            PhotoGallery(false),
            const SizedBox(height: MARGIN),

            Row(
              children: const [
                Icon(Icons.description),
                SizedBox(width: MARGIN),
                Text('description'),
              ],
            ),
            const SizedBox(height: MARGIN),

            _comment("initial comment", context, username: "report sender"),

            const Divider(
              thickness: 5,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: MARGIN),

            for (var i = 0; i < 5; i++) _comment("body $i", context),

            const TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Comment',
              ),
              textInputAction: TextInputAction.send,
            ),
            const SizedBox(height: MARGIN),
          ],
        );
      },
    );
  }
}
