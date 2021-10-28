import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';

import 'package:client/misc/const.dart';


class NonePage extends StatelessWidget {
  const NonePage({Key? key}): super(key: key);

  final title = "404";
  static const route = "/404";

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            margin: const EdgeInsets.only(top: MARGIN, bottom: MARGIN),
            child: Card(
              child: Container(
                margin: const EdgeInsets.all(MARGIN),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Shh... just pass by...", style: Theme.of(context).textTheme.headline5),
                    const SizedBox(height: MARGIN),
                    ElevatedButton(
                      onPressed: () => SystemNavigator.pop(),
                      child: const Text('Return'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
