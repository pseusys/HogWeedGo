import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'package:client/models/report.dart';
import 'package:client/hogweedgo.dart';


class StatusRepository {
  final statusController = StreamController<bool>();
  final resetController = StreamController();
  final reportController = StreamController<Report>();


  Future<void> getReports() async {
    final response = await get(Uri.parse("${HogWeedGo.server}/api/reports"));
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    resetController.add(null);
    parsed.map<Report>((json) => Report.fromJson(json)).toList().forEach((elem) => reportController.add(elem));
  }

  Future<void> healthCheck() async {
    final response = await get(Uri.parse("${HogWeedGo.server}/healthcheck")).timeout(const Duration(seconds: 5));
    statusController.add(response.statusCode == 200);
  }

  void dispose() {
    resetController.close();
    reportController.close();
    statusController.close();
  }
}
