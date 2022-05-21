import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:client/blocs/status/status_event.dart';
import 'package:client/blocs/status/status_state.dart';

import 'package:client/models/report.dart';
import 'package:client/repositories/status_repository.dart';


class StatusBloc extends Bloc<StatusEvent, StatusState> {
  final StatusRepository _statusRepository;

  late StreamSubscription<Report> _reportSubscription;
  late StreamSubscription<void> _resetSubscription;
  late StreamSubscription<bool> _statusSubscription;

  StatusBloc(this._statusRepository) : super(StatusState([], false)) {
    on<ReportAdded>((event, emit) => emit(state.addReport(event.report)));
    on<ReportsReset>((event, emit) => emit(state.resetReports()));
    on<StatusChanged>((event, emit) => emit(state.setStatus(event.status)));
    on<ReportsRequested>((event, emit) => _statusRepository.getReports());
    on<StatusRequest>((event, emit) => _statusRepository.healthCheck());

    _reportSubscription = _statusRepository.reportController.stream.listen((current) => add(ReportAdded(current)));
    _resetSubscription = _statusRepository.resetController.stream.listen((_) => add(const ReportsReset()));
    _statusSubscription = _statusRepository.statusController.stream.listen((current) => add(StatusChanged(current)));

    add(const StatusRequest());
  }

  @override
  Future<void> close() {
    _reportSubscription.cancel();
    _resetSubscription.cancel();
    _statusSubscription.cancel();
    _statusRepository.dispose();
    return super.close();
  }
}
