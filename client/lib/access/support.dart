import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
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
    String toastMessage = "";
    switch (statusCode) {
      case 200:
        print(body);
        return;
      case 400:
        toastMessage = "request error: $generalErrorMessage!";
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
        toastMessage = "unknown!";
    }
    Fluttertoast.showToast(msg: "API error: $toastMessage");
  }
}
