import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';

import 'package:client/blocs/report/report_event.dart';
import 'package:client/blocs/report/report_state.dart';
import 'package:client/misc/const.dart';
import 'package:client/models/report.dart';
import 'package:client/repositories/account_repository.dart';
import 'package:client/repositories/report_repository.dart';
import 'package:client/blocs/report/report_form.dart';


class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _reportRepository;
  final AccountRepository _accountRepository;

  ReportBloc(this._reportRepository, this._accountRepository) : super(ReportState(STP, [])) {
    on<ReportAddressChanged>(_onAddressChanged);
    on<ReportCommentChanged>(_onCommentChanged);
    on<ReportPhotosChanged>(_onPhotosChanged);
    on<ReportPlaceChanged>((event, emit) => emit(state.copyWith(place: event.place)));
    on<ReportSubmitted>(_onSubmitted);
  }

  void _onAddressChanged(ReportAddressChanged event, Emitter<ReportState> emit) {
    final address = Address.dirty(event.address);
    emit(state.copyWith(
      address: address,
      status: Formz.validate([address, state.comment, for (var photo in state.photos) photo]),
    ));
  }

  void _onCommentChanged(ReportCommentChanged event, Emitter<ReportState> emit) {
    final comment = Comment.dirty(event.comment);
    emit(state.copyWith(
      comment: comment,
      status: Formz.validate([comment, state.address, for (var photo in state.photos) photo]),
    ));
  }

  void _onPhotosChanged(ReportPhotosChanged event, Emitter<ReportState> emit) {
    final photos = event.photos.map((e) => Image.dirty(e)).toList();
    emit(state.copyWith(
      photos: photos,
      status: Formz.validate([state.comment, state.address, for (var photo in photos) photo]),
    ));
  }

  void _onSubmitted(ReportSubmitted event, Emitter<ReportState> emit) async {
    if (state.status.isValidated) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));
      try {
        final photos = state.photos.map((e) => e.value.first).toList();
        // TODO: get species name from detector.
        final type = "Hogweed | ${state.probability}";
        await _reportRepository.setReport(_accountRepository.getToken() ?? "", Report.send(state.address.value, state.comment.value, state.place, type), photos);
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (_) {
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    }
  }

  @override
  Future<void> close() {
    _accountRepository.dispose();
    return super.close();
  }
}
