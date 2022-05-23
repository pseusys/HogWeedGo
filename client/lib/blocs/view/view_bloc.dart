import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:formz/formz.dart';

import 'package:client/blocs/view/view_event.dart';
import 'package:client/blocs/view/view_form.dart';
import 'package:client/blocs/view/view_state.dart';
import 'package:client/models/comment.dart';
import 'package:client/models/report.dart';
import 'package:client/repositories/account_repository.dart';
import 'package:client/repositories/view_repository.dart';


class ViewBloc extends Bloc<ViewEvent, ViewState> {
  final ViewRepository _viewRepository;
  final AccountRepository _accountRepository;

  late StreamSubscription<Report> _currentViewSubscription;

  ViewBloc(Report report, this._viewRepository, this._accountRepository) : super(ViewState(report)) {
    on<ViewChanged>((event, emit) => emit(ViewState(event.current)));
    on<ViewNoteChanged>(_onNoteChanged);
    on<ViewNoteSubmitted>(_onNoteSubmitted);

    _currentViewSubscription = _viewRepository.viewController.stream.listen((current) => add(ViewChanged(current)));

    try {
      _viewRepository.loadView(state.current);
    } catch (_) {
      Fluttertoast.showToast(msg: "API error: requested report can not be loaded!", toastLength: Toast.LENGTH_LONG);
    }
  }

  void _onNoteChanged(ViewNoteChanged event, Emitter<ViewState> emit) {
    final note = Note.dirty(event.note);
    emit(state.copyWith(
      note: note,
      status: Formz.validate([note]),
    ));
  }

  void _onNoteSubmitted(ViewNoteSubmitted event, Emitter<ViewState> emit) async {
    if (state.status.isValidated) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));
      try {
        await _viewRepository.setComment(state.current, await _accountRepository.getToken() ?? "", Comment.send(state.current.id, state.note.value, state.current.subsID));
        return emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (_) {
        Fluttertoast.showToast(msg: "API error: comment can not be set!", toastLength: Toast.LENGTH_LONG);
        return emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    }
  }

  @override
  Future<void> close() {
    _currentViewSubscription.cancel();
    _viewRepository.dispose();
    return super.close();
  }
}
