import 'package:flutter/material.dart';


class FastRoute<T> extends MaterialPageRoute<T> {
  FastRoute(WidgetBuilder builder, RouteSettings settings) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation secondaryAnimation, Widget child) => child;
}
