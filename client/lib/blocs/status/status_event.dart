import 'package:client/models/report.dart';


abstract class StatusEvent {
  const StatusEvent();
}

class ReportsReset extends StatusEvent {
  const ReportsReset();
}

class ReportsRequested extends StatusEvent {
  final bool sync;
  const ReportsRequested(this.sync);
}

class ReportAdded extends StatusEvent {
  final Report report;
  const ReportAdded(this.report);
}

class ReportsAdded extends StatusEvent {
  final List<Report> reports;
  const ReportsAdded(this.reports);
}

class StatusRequest extends StatusEvent {
  const StatusRequest();
}

class StatusChanged extends StatusEvent {
  final bool status;
  const StatusChanged(this.status);
}
