import 'package:client/models/report.dart';


abstract class ViewEvent {
  const ViewEvent();
}

class ViewChanged extends ViewEvent {
  final Report current;
  const ViewChanged(this.current);
}

class CommentLeft extends ViewEvent {
  final String comment;
  const CommentLeft(this.comment);
}
