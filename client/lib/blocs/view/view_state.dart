import 'package:formz/formz.dart';

import 'package:client/blocs/view/view_form.dart';
import 'package:client/models/report.dart';


class ViewState {
  final FormzStatus status;
  final Report current;
  final Note note;

  ViewState(this.current, {
    this.status = FormzStatus.pure,
    this.note = const Note.pure(),
  });

  ViewState copyWith({FormzStatus? status, Note? note}) => ViewState(
    current,
    status: status ?? this.status,
    note: note ?? this.note,
  );
}
