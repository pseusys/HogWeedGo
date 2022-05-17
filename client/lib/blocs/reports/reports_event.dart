import 'package:client/models/report.dart';


abstract class ReportsEvent {
  const ReportsEvent();
}

class ReportsReset extends ReportsEvent {
  const ReportsReset();
}

class ReportsRequested extends ReportsEvent {
  const ReportsRequested();
}

class ReportsAdded extends ReportsEvent {
  const ReportsAdded(this.report);
  final Report report;
}
