import 'dart:convert';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:client/models/report.dart';
import 'package:client/main.dart';
import 'package:client/models/user.dart';
import 'package:client/access/support.dart';
import 'package:client/models/comment.dart';


Future<bool> healthcheck() async {
  final response = await get(Uri.parse("${HogWeedGo.server}/healthcheck"));
  return Future.value(response.statusCode == 200);
}

Future<List<Report>> getReports() async {
  final response = await get(Uri.parse("${HogWeedGo.server}/reports"));
  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
  return parsed.map<Report>((json) => Report.fromJson(json)).toList();
}

Future<Report> setReport(Report report, List<String> files) async {
  final request = MultipartRequest('POST', Uri.parse("${HogWeedGo.server}/reports"))
    ..auth()
    ..fields['data'] = jsonEncode(report.toJson());
  for (var file in files) {
    final type = lookupMimeType(file);
    if (type != null) {
      request.files.add(await MultipartFile.fromPath('photos', file, contentType: MediaType.parse(type)));
    }
  }
  final response = await request.response();
  return Report.fromJson(response.json());
}

Future<User> getUser(int id) async {
  final response = await get(Uri.parse("${HogWeedGo.server}/users/$id"));
  return User.fromJson(response.json());
}

Future<Comment> setComment(int report, Comment comment) async {
  final request = Request('POST', Uri.parse("${HogWeedGo.server}/comments"))
    ..auth()
    ..body = jsonEncode(comment.toJson());
  final response = await request.response();
  return Comment.fromJson(response.json());
}
