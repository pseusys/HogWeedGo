import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:client/blocs/account/account_event.dart';
import 'package:client/blocs/account/account_state.dart';
import 'package:client/repositories/account_repository.dart';


class AccountBloc extends Bloc<AccountEvent, AccountState> {
  late StreamSubscription<bool> _authenticationStatusSubscription;
  final AccountRepository _accountRepository;

  AccountBloc(this._accountRepository) : super(const AccountState.unauthenticated()) {
    on<StatusChanged>(_onStatusChanged);
    on<AuthenticationRequested>((event, emit) => _accountRepository.authenticate(event.email, event.password, event.code));
    on<LoginRequested>((event, emit) => _accountRepository.logIn(event.email, event.password));
    on<EmailProveRequested>((event, emit) => _accountRepository.proveEmail(event.email));
    on<NameChangeRequested>((event, emit) => _accountRepository.setup(name: event.name));
    on<EmailChangeRequested>((event, emit) => _accountRepository.setup(email: event.email, code: event.code));
    on<PasswordChangeRequested>((event, emit) => _accountRepository.setup(password: event.password));
    on<LogoutRequested>((event, emit) => _accountRepository.logOut());
    on<LeaveRequested>((event, emit) => _accountRepository.leave());

    _authenticationStatusSubscription = _accountRepository.controller.stream.listen((status) => add(StatusChanged(status)));

    _accountRepository.checkAuth();
  }

  void _onStatusChanged(StatusChanged event, Emitter<AccountState> emit) async {
    if (event.status && !state.status) {
      final user = await _accountRepository.profile();
      return emit(user != null ? AccountState.authenticated(user) : const AccountState.unauthenticated());
    } else if (!event.status && state.status) {
      return emit(const AccountState.unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    _accountRepository.dispose();
    return super.close();
  }
}
