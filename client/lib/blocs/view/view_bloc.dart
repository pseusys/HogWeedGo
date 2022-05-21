import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:client/blocs/view/view_event.dart';
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

    on<InfoRequested>((event, emit) => _viewRepository.loadView(state.current));

    on<CommentLeft>((event, emit) {
      final comment = Comment(state.current.id, event.comment, state.current.subsID);
      _viewRepository.setComment(state.current, _accountRepository.getToken() ?? "", comment);
    });

    _currentViewSubscription = _viewRepository.viewController.stream.listen((current) => add(ViewChanged(current)));

    add(const InfoRequested());
  }

  @override
  Future<void> close() {
    _currentViewSubscription.cancel();
    _viewRepository.dispose();
    _accountRepository.dispose();
    return super.close();
  }
}
