import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:client/models/report.dart';
import 'package:client/hogweedgo.dart';
import 'package:client/repositories/support.dart';


class ReportRepository {
  final reportController = StreamController<Report>();


  Future<void> setReport(String token, Report report, List<XFile> files) async {
    final request = MultipartRequest('POST', Uri.parse("${HogWeedGo.server}/api/reports"))
      ..fields['data'] = jsonEncode(report.toJson());
    await request.auth(token);
    for (var file in files) {
      final type = file.mimeType ?? lookupMimeType(file.name);
      if (type != null) request.files.add(MultipartFile.fromBytes('photos', await file.readAsBytes(), contentType: MediaType.parse(type)));
    }
    final response = await request.response();
    reportController.add(Report.fromJson(response.json()));
  }
}
