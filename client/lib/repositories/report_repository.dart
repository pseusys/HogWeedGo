import 'dart:async';
import 'dart:convert';

import 'package:client/repositories/support.dart';
import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:client/models/report.dart';
import 'package:client/hogweedgo.dart';

class ReportRepository {
  final reportController = StreamController<Report>();


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
}
