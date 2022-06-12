import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:client/blocs/auth/auth_event.dart';
import 'package:client/blocs/auth/auth_state.dart';
import 'package:client/models/user.dart';
import 'package:client/repositories/auth_repository.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late StreamSubscription<String?> _currentTokenSubscription;
  late StreamSubscription<String?> _currentEmailSubscription;
  late StreamSubscription<User?> _currentUserSubscription;
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState.out()) {
    on<TokenChanged>((event, emit) => emit(state.copyWith(token: event.token)));
    on<UserChanged>((event, emit) => emit(state.copyWith(user: event.user)));
    on<EmailChanged>((event, emit) => emit(state.copyWith(email: event.email)));

    _currentTokenSubscription = _authRepository.tokenController.stream.listen((token) => add(TokenChanged(token)));
    _currentEmailSubscription = _authRepository.emailController.stream.listen((email) => add(EmailChanged(email)));
    _currentUserSubscription = _authRepository.userController.stream.listen((user) => add(UserChanged(user)));

    _authRepository.load();
  }

  @override
  Future<void> close() {
    _currentTokenSubscription.cancel();
    _currentEmailSubscription.cancel();
    _currentUserSubscription.cancel();
    _authRepository.dispose();
    return super.close();
  }
}
