import 'package:http/http.dart';

import 'package:client/access/support.dart';
import 'package:client/main.dart';


String _token = "";
String get token => _token;
bool get authenticated => _token == "";


Future<bool> proveEmail(String email) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/prove_email?email=$email"))
    ..addExceptionHandler("Error!");
  return response.statusCode == 200;
}

Future<bool> authenticate(String email, String password, String code) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/auth?email=$email&password=$password&code=$code"))
    ..addExceptionHandler("Error!");
  if (response.statusCode == 200) _token = response.body;
  return response.statusCode == 200;
}

Future<bool> logIn(String email, String password) async {
  final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/log_in?email=$email&password=$password"))
    ..addExceptionHandler("Error!");
  if (response.statusCode == 200) _token = response.body;
  return response.statusCode == 200;
}

Future<bool> setup(String email, String password, String code) async {
  final request = Request('GET', Uri.parse("${HogWeedGo.server}/api/me/setup?email=$email&password=$password&code=$code"))
    ..auth();
  final response = await request.response()
    ..addExceptionHandler("Error!");
  return response.statusCode == 200;
}

Future<bool> logOut(String email, String password, String code) async {
  final request = Request('GET', Uri.parse("${HogWeedGo.server}/api/me/log_out"))
    ..auth();
  final response = await request.response()
    ..addExceptionHandler("Error!");
  if (response.statusCode == 200) _token = "";
  return response.statusCode == 200;
}

Future<bool> leave(String email, String password, String code) async {
  final request = Request('GET', Uri.parse("${HogWeedGo.server}/api/me/leave"))
    ..auth();
  final response = await request.response()
    ..addExceptionHandler("Error!");
  if (response.statusCode == 200) _token = "";
  return response.statusCode == 200;
}
