import 'package:flutter/material.dart';


extension NavigatorStateExtension on NavigatorState {
  void popAllAndPushNamed(String routeName, {Object? arguments}) {
    popUntil(ModalRoute.withName(Navigator.defaultRouteName));
    pushNamed(routeName, arguments: arguments);
  }
}
