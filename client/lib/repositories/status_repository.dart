import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'package:client/models/report.dart';
import 'package:client/hogweedgo.dart';


class StatusRepository {
  final statusController = StreamController<bool>();
  final resetController = StreamController();
  final reportController = StreamController<Report>();
  final reportsController = StreamController<List<Report>>();


  Future<void> getReports(bool sync) async {
    final response = await get(Uri.parse("${HogWeedGo.server}/api/reports"));
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    resetController.add(null);
    final reports = parsed.map<Report>((json) => Report.fromJson(json)).toList();
    if (sync) {
      reports.forEach((elem) => reportController.add(elem));
    } else {
      reportsController.add(reports);
    }
  }

  Future<void> healthCheck() async {
    final response = await get(Uri.parse("${HogWeedGo.server}/healthcheck")).timeout(const Duration(seconds: 5));
    statusController.add(response.statusCode == 200);
  }

  void dispose() {
    statusController.close();
    resetController.close();
    reportController.close();
    reportsController.close();
  }
}
