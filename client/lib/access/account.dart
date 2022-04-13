import 'package:http/http.dart';

import 'package:client/main.dart';


String _token = "";
String get token => _token;


Future proveEmail(String email, String password, String code) async {
  final response = await get(Uri.parse("${HogWeedGo.server}/api/me/prove_email?email=$email"));
  if (response.statusCode == 200) {
    // TODO: make toast.
  }
}

Future authenticate(String email, String password, String code) async {
  final response = await get(Uri.parse("${HogWeedGo.server}/api/me/auth?email=$email&password=$password&code=$code"));
  if (response.statusCode == 200) {
    _token = response.body;
  }
}

Future logIn(String email, String password) async {
  final response = await get(Uri.parse("${HogWeedGo.server}/api/me/log_in?email=$email&password=$password"));
  if (response.statusCode == 200) {
    _token = response.body;
  }
}
