import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:client/blocs/view/view_event.dart';
import 'package:client/blocs/view/view_state.dart';
import 'package:client/models/comment.dart';
import 'package:client/models/report.dart';
import 'package:client/repositories/account_repository.dart';
import 'package:client/repositories/api_repository.dart';


class ViewBloc extends Bloc<ViewEvent, ViewState> {
  final ApiRepository _apiRepository;
  final AccountRepository _accountRepository;

  late StreamSubscription<Report> _currentViewSubscription;

  ViewBloc(this._apiRepository, this._accountRepository) : super(ViewState(null)) {
    on<ViewChanged>((event, emit) => emit(ViewState(event.current)));

    on<InfoRequested>((event, emit) => _apiRepository.loadView(event.current));

    on<CommentLeft>((event, emit) {
      final comment = Comment(state.current!.id, event.comment, state.current!.subsID);
      _apiRepository.setComment(_accountRepository.getToken() ?? "", comment);
    });

    _currentViewSubscription = _apiRepository.viewController.stream.listen((current) => add(ViewChanged(current)));
  }

  @override
  Future<void> close() {
    _currentViewSubscription.cancel();
    _apiRepository.disposeView();
    return super.close();
  }
}
