import 'package:client/models/report.dart';


abstract class ViewEvent {
  const ViewEvent();
}

class ViewChanged extends ViewEvent {
  final Report current;
  const ViewChanged(this.current);
}

class ViewNoteChanged extends ViewEvent {
  final String note;
  const ViewNoteChanged(this.note);
}

class ViewNoteSubmitted extends ViewEvent {
  const ViewNoteSubmitted();
}
