import 'package:flutter/material.dart';

import 'const.dart';


class NonePage extends StatelessWidget {
  const NonePage({Key? key}): super(key: key);

  final title = "404";
  static const route = "/404";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                margin: const EdgeInsets.only(top: margins, bottom: margins),
                child: Card(
                    child: Container(
                        margin: const EdgeInsets.all(margins),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Shh... just pass by...", style: Theme.of(context).textTheme.headline5),
                              const SizedBox(height: margins),
                              ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Return')
                              )
                            ]
                        )
                    )
                )
            )
        )
    );
  }
}
