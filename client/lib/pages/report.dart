import 'package:flutter/material.dart';


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
    return Scaffold(appBar: AppBar(title: Text(widget.title)));
  }
}
