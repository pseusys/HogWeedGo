import 'package:flutter/material.dart';

import 'package:client/views/base_dialogs.dart';
import 'package:client/pages/auth.dart';


class AuthDialog extends YesOrNoDialog {
  static const route = "/auth_dialog";
  const AuthDialog({Key? key}) : super("Would you like to join us?", "Requested action requires authentication. Would you like to continue and join HogWeedGo?", yesDestination: AuthPage.route, key: key);
}