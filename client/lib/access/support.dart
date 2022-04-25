import 'dart:convert';

import 'package:http/http.dart';

import 'package:client/access/account.dart';


Client base = Client();

extension RequestSupport on BaseRequest {
  void auth() {
    headers.putIfAbsent("Authentication", () => token);
  }

  Future<Response> response() async {
    final stream = await base.send(this);
    return await Response.fromStream(stream);
  }
}

extension ResponseSupport on Response {
  Map<String, dynamic> json() {
    return jsonDecode(body).cast<Map<String, dynamic>>();
  }

  void addExceptionHandler(String generalErrorMessage) {
    if (statusCode == 200) {
      print(body);
    } else if (statusCode == 400) {
      print(generalErrorMessage);
    } else if (statusCode == 401) {
      print("Wrong or expired code!");
    } else if (statusCode == 403) {
      print("User already exists!");
    } else if (statusCode == 429) {
      print("Requesting too fast!");
    }
  }
}
