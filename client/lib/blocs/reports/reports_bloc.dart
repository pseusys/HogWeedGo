import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:client/blocs/reports/reports_event.dart';
import 'package:client/blocs/reports/reports_state.dart';

import 'package:client/blocs/view/view_event.dart';
import 'package:client/blocs/view/view_state.dart';
import 'package:client/models/comment.dart';
import 'package:client/models/report.dart';
import 'package:client/repositories/account_repository.dart';
import 'package:client/repositories/api_repository.dart';


class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ApiRepository _apiRepository;

  late StreamSubscription<Report> _reportSubscription;
  late StreamSubscription<void> _resetSubscription;

  ReportsBloc(this._apiRepository) : super(ReportsState([])) {
    on<ReportsAdded>((event, emit) => emit(state.plus(event.report)));

    on<ReportsReset>((event, emit) => emit(ReportsState([])));

    on<ReportsRequested>((event, emit) => _apiRepository.getReports());

    _reportSubscription = _apiRepository.reportController.stream.listen((current) => add(ReportsAdded(current)));

    _resetSubscription = _apiRepository.resetController.stream.listen((_) => add(const ReportsReset()));
  }

  @override
  Future<void> close() {
    _reportSubscription.cancel();
    _resetSubscription.cancel();
    _apiRepository.disposeView();
    return super.close();
  }
}
