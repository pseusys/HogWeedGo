import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/access/support.dart';
import 'package:client/main.dart';
import 'package:client/pages/auth.dart';
import 'package:client/views/base_dialogs.dart';
import 'package:client/models/user.dart';



class Token {
  static const _TOKEN_KEY = "authorization";

  static Token? _singleton;
  static late SharedPreferences prefs;

  String _token;

  static Future<Token> _instance() async {
    if (_singleton == null) {
      _singleton = Token._internal("");
      prefs = await SharedPreferences.getInstance();
      if (_singleton!._token == "") _singleton!._token = prefs.getString(_TOKEN_KEY) ?? "";
    }
    return _singleton!;
  }

  static Future<String> token() async {
    return (await _instance())._token;
  }

  static Future<bool> authenticated() async {
    return (await _instance())._token != "";
  }

  static _setToken (String? value) async {
    final inst = await _instance();
    if (value != null) {
      prefs.setString(_TOKEN_KEY, value);
    } else {
      prefs.remove(_TOKEN_KEY);
    }
    inst._token = value ?? "";
  }

  Token._internal(this._token);
}


Future<bool> proveEmail(String email) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/prove_email?email=$email"));
  return response.statusCode == 200;
}

Future<bool> authenticate(String email, String password, String code) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/auth?email=$email&password=$password&code=$code"))
    ..addExceptionHandler(generalErrorMessage: "can not authenticate user with given email and password");
  if (response.statusCode == 200) Token._setToken(response.body);
  return response.statusCode == 200;
}

Future<bool> logIn(String email, String password) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/log_in?email=$email&password=$password"))
    ..addExceptionHandler(generalErrorMessage: "can not log in user with given email and password");
  if (response.statusCode == 200) Token._setToken(response.body);
  return response.statusCode == 200;
}

Future<bool> setup({String? email, String? password, String? code, String? image, String? name}) async {
  final emailPart = "email=$email&code=$code";
  final passwordPart = "password=$password";
  final namePart = "name=$name";
  final request = MultipartRequest('POST', Uri.parse("${HogWeedGo.server}/api/me/setup?${[if (email != null) emailPart, if (password != null) passwordPart, if (name != null) namePart].join("&")}"));
  await request.auth();
  if (image != null) {
    final type = lookupMimeType(image);
    if (type != null) request.files.add(await MultipartFile.fromPath('photo', image, contentType: MediaType.parse(type)));
  }
  final response = await request.response()
    ..addExceptionHandler(generalErrorMessage: "at least one of the requested properties could not be changed");
  return response.statusCode == 200;
}

Future<User> profile() async {
  final request = Request('GET', Uri.parse("${HogWeedGo.server}/api/me/profile"));
  await request.auth();
  final response = await request.response()
    ..addExceptionHandler();
  return User.fromJson(response.json());
}

Future<bool> logOut() async {
  final request = Request('DELETE', Uri.parse("${HogWeedGo.server}/api/me/log_out"));
  await request.auth();
  final response = await request.response()
    ..addExceptionHandler();
  if (response.statusCode == 200) Token._setToken(null);
  return response.statusCode == 200;
}

Future<bool> leave() async {
  final request = Request('DELETE', Uri.parse("${HogWeedGo.server}/api/me/leave"));
  await request.auth();
  final response = await request.response()
    ..addExceptionHandler();
  if (response.statusCode == 200) Token._setToken(null);
  return response.statusCode == 200;
}


class AuthDialog extends YesOrNoDialog {
  static const route = "/auth_dialog";
  const AuthDialog({Key? key}) : super("Would you like to join us?", "Requested action requires authentication. Would you like to continue and join HogWeedGo?", yesDestination: AuthPage.route, key: key);
}
