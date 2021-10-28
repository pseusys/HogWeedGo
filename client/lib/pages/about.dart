import 'package:client/misc/helpers.dart';
import 'package:flutter/material.dart';

import 'package:client/views/main_drawer.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}): super(key: key);

  final title = "About";
  static const route = "/about";

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        drawer: const MainDrawer(),
      ),
    );
  }
}
