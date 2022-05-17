import 'package:client/models/report.dart';


abstract class ViewEvent {
  const ViewEvent();
}

class ViewChanged extends ViewEvent {
  const ViewChanged(this.current);
  final Report current;
}

class InfoRequested extends ViewEvent {
  const InfoRequested(this.current);
  final Report current;
}

class CommentLeft extends ViewEvent {
  const CommentLeft(this.comment);
  final String comment;
}
