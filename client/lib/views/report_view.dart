import 'package:flutter/material.dart';


class ReportView extends StatelessWidget {
  const ReportView({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          color: Colors.amber,
          child: Center(
            child: Column(
              children: [
                const Text('address'),
                Row(children: const [Text('date_time'), Text('sub')]),
                const Text('lng_lat'),
                const Divider(),
                const Text('comment'),
              ],
            ),
          ),
        );
      },
    );
  }
}
