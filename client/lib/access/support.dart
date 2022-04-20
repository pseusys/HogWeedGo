import 'dart:convert';

import 'package:http/http.dart';

import 'package:client/access/account.dart';


extension RequestSupport on BaseRequest {
  void auth() {
    headers.putIfAbsent("Authentication", () => token);
  }

  Future<Response> response() async {
    final stream = await send();
    return await Response.fromStream(stream);
  }
}

extension ResponseSupport on Response {
  Map<String, dynamic> json() {
    return jsonDecode(body).cast<Map<String, dynamic>>();
  }

  void addExceptionHandler() {

  }
}
