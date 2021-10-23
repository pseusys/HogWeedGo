import 'package:flutter/material.dart';

import 'package:client/views/photo_gallery.dart';
import 'package:client/misc/const.dart';


class ReportView extends StatelessWidget {
  const ReportView({Key? key}): super(key: key);

  Widget _comment(String body, { String username = "Anonymous", String? photoURL }) {
    return Row(
      children: [
        CircleAvatar(
          child: photoURL == null ? Text(username[0]) : Image.network(photoURL),
        ),
        Column(
          children: [
            Text(username),
            Text(body),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, ScrollController scrollController) {
        return Column(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: OFFSET * 2,
                height: GAP,
                margin: const EdgeInsets.symmetric(vertical: GAP),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MARGIN),
                  color: Colors.grey,
                ),
              ),
            ),

            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: const [
                      Text('type'),
                      Chip(
                        avatar: CircleAvatar(
                          child: Text('ST'),
                        ),
                        label: Text('status'),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      Column(
                        children: const [
                          Text('address'),
                          Text('coords'),
                        ],
                      ),
                    ],
                  ),

                  Row(
                    children: const [
                      Icon(Icons.access_time),
                      Text('time'),
                    ],
                  ),

                  const PhotoGallery(false),

                  Row(
                    children: const [
                      Icon(Icons.description),
                      Text('description'),
                    ],
                  ),

                  _comment("initial comment", username: "report sender"),

                  const Divider(
                    height: 20,
                    thickness: 5,
                    indent: 20,
                    endIndent: 20,
                  ),

                  for (var i = 0; i < 5; i++) _comment("body $i")
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
