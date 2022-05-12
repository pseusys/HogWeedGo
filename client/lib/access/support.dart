import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import 'package:client/access/account.dart';


Client base = Client();

extension RequestSupport on BaseRequest {
  Future auth() async {
    final token = await Token.token();
    headers.putIfAbsent("Authorization", () => token);
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

  void addExceptionHandler({String generalErrorMessage = "unknown"}) {
    String toastMessage = "";
    print(body);
    switch (statusCode) {
      case 200:
        return;
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
        toastMessage = "unknown!";
    }
    Fluttertoast.showToast(msg: "API error: $toastMessage", toastLength: Toast.LENGTH_LONG);
  }
}
