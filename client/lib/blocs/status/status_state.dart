import 'package:client/models/report.dart';


class StatusState {
  final List<Report> reports;
  bool status;

  StatusState(this.reports, this.status);

  StatusState addReport(Report report) {
    reports.add(report);
    return this;
  }

  StatusState resetReports() {
    reports.clear();
    return this;
  }

  StatusState setStatus(bool current) {
    status = current;
    return this;
  }
}
