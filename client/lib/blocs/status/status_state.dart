import 'package:client/models/report.dart';


class StatusState {
  final List<Report> reports;
  bool status;

  StatusState(this.reports, this.status);

  StatusState addReport(Report report) => StatusState(reports.followedBy([report]).toList(), status);

  StatusState setReports(List<Report> current) => StatusState(current, status);

  StatusState resetReports() => StatusState([], status);

  StatusState setStatus(bool current) => StatusState(reports, current);
}
