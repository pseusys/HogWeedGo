import 'dart:async';
import 'dart:convert';

import 'package:client/repositories/support.dart';
import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:client/models/report.dart';
import 'package:client/hogweedgo.dart';
import 'package:client/models/user.dart';
import 'package:client/models/comment.dart';


class ApiRepository {
  final resetController = StreamController();
  final reportController = StreamController<Report>();
  final viewController = StreamController<Report>();

  final List<Report> reports = [];

  Report? _view;


  Future<void> getReports() async {
    final response = await get(Uri.parse("${HogWeedGo.server}/api/reports"));
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    resetController.add(null);
    parsed.map<Report>((json) => Report.fromJson(json)).toList().forEach((elem) => reportController.add(elem));
  }

  Future<void> setReport(String token, Report report, List<String> files) async {
    final request = MultipartRequest('POST', Uri.parse("${HogWeedGo.server}/api/reports"))
      ..fields['data'] = jsonEncode(report.toJson());
    await request.auth(token);
    for (var file in files) {
      final type = lookupMimeType(file);
      if (type != null) {
        request.files.add(await MultipartFile.fromPath('photos', file, contentType: MediaType.parse(type)));
      }
    }
    final response = await request.response()
      ..addExceptionHandler();
    reportController.add(Report.fromJson(response.json()));
  }

  Future<void> loadView(Report view) async {
    _view = view;
    final response = await get(Uri.parse("${HogWeedGo.server}/api/users/${_view!.subs}"));
    _view!.subs = User.fromJson(response.json());
    viewController.add(_view!);
  }

  Future<void> setComment(String token, Comment comment) async {
    final request = Request('POST', Uri.parse("${HogWeedGo.server}/api/comments"))
      ..body = jsonEncode(comment.toJson());
    await request.auth(token);
    final response = await request.response()
      ..addExceptionHandler();
    if (_view != null) {
      _view!.comments.add(Comment.fromJson(response.json()));
      viewController.add(_view!);
    }
  }

  void disposeView() => viewController.close();
}
