import 'package:client/models/report.dart';


class ReportsState {
  final List<Report> reports;

  ReportsState(this.reports);

  ReportsState plus(Report report) {
    reports.add(report);
    return this;
  }
}
