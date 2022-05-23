import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';


//TODO: create my cookiejar.
Client base = Client();
Map<String, String> _cookies = {};
Map<String, String> _headers = {};

extension RequestSupport on BaseRequest {
  auth(String? token) {
    if (token == null) throw Exception("No token available for authorization!");
    headers.putIfAbsent("Authorization", () => token);
  }

  head() {
    headers.addAll(_headers);
  }

  Future<Response> response() async {
    final stream = await base.send(this);
    final response = await Response.fromStream(stream);
    _updateCookie(response);
    return response;
  }

  void _updateCookie(Response response) {
    String? allSetCookie = response.headers['set-cookie'];
    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');
      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');
        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }
      _headers['cookie'] = _generateCookieHeader();
    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.isNotEmpty) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];
        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;
        _cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";
    for (var key in _cookies.keys) {
      if (cookie.isNotEmpty) cookie += ";";
      cookie += key + "=" + _cookies[key]!;
    }
    return cookie;
  }
}

extension ResponseSupport on Response {
  Map<String, dynamic> json() {
    return jsonDecode(body) as Map<String, dynamic>;
  }

  // TODO: check if all request surrounded with try .. catch + add exception handlers depending on error code.
  void addExceptionHandler({String generalErrorMessage = "unknown"}) {
    String toastMessage = "";
    if (kDebugMode) print(body);
    switch (statusCode) {
      case 400:
        toastMessage = "request error, $generalErrorMessage!";
        break;
      case 401:
        toastMessage = "wrong or expired code!";
        break;
      case 403:
        toastMessage = "user already exists!";
        break;
      case 429:
        toastMessage = "requesting too fast!";
        break;
      default:
        return;
    }
    Fluttertoast.showToast(msg: "API error: $toastMessage", toastLength: Toast.LENGTH_LONG);
  }
}
