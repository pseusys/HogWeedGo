import 'dart:async';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/hogweedgo.dart';
import 'package:client/models/user.dart';
import 'package:client/repositories/support.dart';


class AccountRepository {
  static const _TOKEN_KEY = "authorization";

  final _controller = StreamController<bool>();
  String? _token;


  String? getToken() => _token;

  Future<void> _setToken (String? value) async {
    _token = value ?? "";
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      prefs.setString(_TOKEN_KEY, value);
    } else {
      prefs.remove(_TOKEN_KEY);
    }
    _controller.add(_token != "");
  }

  Stream<bool> get status async* {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_TOKEN_KEY) ?? "";
    }
    yield* _controller.stream;
  }


  Future<void> proveEmail(String email) => base.get(Uri.parse("${HogWeedGo.server}/api/me/prove_email?email=$email"));

  Future<User?> profile() async {
    final request = Request('GET', Uri.parse("${HogWeedGo.server}/api/me/profile"))
      ..auth(getToken());
    final response = await request.response()
      ..addExceptionHandler();
    return User.fromJson(response.json());
  }


  Future<void> authenticate(String email, String password, String code) async {
    final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/auth?email=$email&password=$password&code=$code"))
      ..addExceptionHandler(generalErrorMessage: "can not authenticate user with given email and password");
    if (response.statusCode == 200) _setToken(response.body);
  }

  Future<void> logIn(String email, String password) async {
    final response = await base.get(Uri.parse("${HogWeedGo.server}/api/me/log_in?email=$email&password=$password"))
      ..addExceptionHandler(generalErrorMessage: "can not log in user with given email and password");
    if (response.statusCode == 200) _setToken(response.body);
  }

  Future<void> setup({String? email, String? password, String? code, String? image, String? name}) async {
    final emailPart = "email=$email&code=$code";
    final passwordPart = "password=$password";
    final namePart = "name=$name";
    final request = MultipartRequest('POST', Uri.parse("${HogWeedGo.server}/api/me/setup?${[if (email != null) emailPart, if (password != null) passwordPart, if (name != null) namePart].join("&")}"))
      ..auth(getToken());
    if (image != null) {
      final type = lookupMimeType(image);
      if (type != null) request.files.add(await MultipartFile.fromPath('photo', image, contentType: MediaType.parse(type)));
    }
    final response = await request.response()
      ..addExceptionHandler(generalErrorMessage: "at least one of the requested properties could not be changed");
    _controller.add(response.statusCode == 200);
  }

  Future<void> logOut() async {
    final request = Request('DELETE', Uri.parse("${HogWeedGo.server}/api/me/log_out"))
      ..auth(getToken());
    final response = await request.response()
      ..addExceptionHandler();
    if (response.statusCode == 200) _setToken(null);
  }

  Future<void> leave() async {
    final request = Request('DELETE', Uri.parse("${HogWeedGo.server}/api/me/leave"))
      ..auth(getToken());
    final response = await request.response()
      ..addExceptionHandler();
    if (response.statusCode == 200) _setToken(null);
  }

  void dispose() => _controller.close();
}
