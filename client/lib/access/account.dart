import 'package:flutter/cupertino.dart';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:client/access/support.dart';
import 'package:client/main.dart';
import 'package:client/pages/auth.dart';
import 'package:client/views/base_dialogs.dart';


String _token = "";
String get token => _token;
bool get authenticated => _token == "";


Future<bool> proveEmail(String email) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/prove_email?email=$email"));
  return response.statusCode == 200;
}

Future<bool> authenticate(String email, String password, String code) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/auth?email=$email&password=$password&code=$code"))
    ..addExceptionHandler("can not authenticate user with given email and password");
  if (response.statusCode == 200) _token = response.body;
  return response.statusCode == 200;
}

Future<bool> logIn(String email, String password) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/log_in?email=$email&password=$password"))
    ..addExceptionHandler("can not log in user with given email and password");
  if (response.statusCode == 200) _token = response.body;
  return response.statusCode == 200;
}

Future<bool> setup({String? email, String? password, String? code, String? image, String? name}) async {
  final emailPart = "email=$email&code=$code";
  final passwordPart = "password=$password";
  final namePart = "name=$name";
  final request = MultipartRequest('GET', Uri.parse("${HogWeedGo.server}/api/me/setup?${[if (emailPart.isNotEmpty) emailPart, if (passwordPart.isNotEmpty) passwordPart, if (namePart.isNotEmpty) namePart].join("&")}"))
    ..auth();
  if (image != null) {
    final type = lookupMimeType(image);
    if (type != null) request.files.add(await MultipartFile.fromPath('photo', image, contentType: MediaType.parse(type)));
  }
  final response = await request.response()
    ..addExceptionHandler("at least one of the requested properties could not be changed");
  return response.statusCode == 200;
}

Future<bool> logOut() async {
  final request = Request('GET', Uri.parse("${HogWeedGo.server}/api/me/log_out"))
    ..auth();
  final response = await request.response();
  if (response.statusCode == 200) _token = "";
  return response.statusCode == 200;
}

Future<bool> leave() async {
  final request = Request('GET', Uri.parse("${HogWeedGo.server}/api/me/leave"))
    ..auth();
  final response = await request.response();
  if (response.statusCode == 200) _token = "";
  return response.statusCode == 200;
}


void showAuthDialog(BuildContext context) async {
  final auth = await yesOrNoDialog(context, "Would you like to join us?", "Requested action requires authentication. Would you like to continue and join HogWeedGo?");
  if (auth) {
    Navigator.of(context, rootNavigator: true).pushNamed(AuthPage.route);
  }
}
