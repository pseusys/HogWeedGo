import 'package:fluttertoast/fluttertoast.dart';
import 'package:formz/formz.dart';

import 'package:client/blocs/auth/auth_form.dart';
import 'package:client/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:client/blocs/login/login_event.dart';
import 'package:client/blocs/login/login_state.dart';
import 'package:client/blocs/login/login_form.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(const LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<CodeChanged>(_onCodeChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmationChanged>(_onConfirmationChanged);
    on<PolicyChanged>(_onPolicyChanged);
    on<ModeChanged>(_onModeChanged);
    on<CodeSubmitted>(_onCodeSubmitted);
    on<FormSubmitted>(_onFormSubmitted);
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      email: email,
      formStatus: Formz.validate([email, state.password, if (state.newAccount) state.confirmation, if (state.newAccount) state.policy]),
    ));
  }

  void _onCodeChanged(CodeChanged event, Emitter<LoginState> emit) {
    final code = Code.dirty(event.code);
    emit(state.copyWith(code: code, codeStatus: Formz.validate([code])));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
      password: password,
      formStatus: Formz.validate([password, state.email, if (state.newAccount) state.confirmation, if (state.newAccount) state.policy]),
    ));
  }

  void _onConfirmationChanged(ConfirmationChanged event, Emitter<LoginState> emit) {
    final confirmation = Confirmation.dirty(state.password, event.confirmation);
    emit(state.copyWith(
      confirmation: confirmation,
      formStatus: Formz.validate([confirmation, state.email, state.password, state.policy]),
    ));
  }

  void _onPolicyChanged(PolicyChanged event, Emitter<LoginState> emit) {
    final policy = Policy.dirty(event.accepted);
    emit(state.copyWith(
      policy: policy,
      formStatus: Formz.validate([policy, state.email, state.password, state.confirmation]),
    ));
  }

  void _onModeChanged(ModeChanged event, Emitter<LoginState> emit) => emit(state.copyWith(
    newAccount: event.newAccount,
    formStatus: Formz.validate([state.email, state.password, if (event.newAccount) state.confirmation, if (event.newAccount) state.policy]),
  ));

  void _onCodeSubmitted(CodeSubmitted event, Emitter<LoginState> emit) async {
    if (state.codeStatus.isValidated) {
      emit(state.copyWith(codeStatus: FormzStatus.submissionInProgress));
      try {
        await _authRepository.authenticate(state.email.value, state.password.value, state.code.value);
        return emit(state.copyWith(codeStatus: FormzStatus.submissionSuccess));
      } catch (_) {
        Fluttertoast.showToast(msg: "API error: image size too large (max. 1GB)!", toastLength: Toast.LENGTH_LONG);
        return emit(state.copyWith(codeStatus: FormzStatus.submissionFailure));
      }
    }
  }

  void _onFormSubmitted(FormSubmitted event, Emitter<LoginState> emit) async {
    if (state.formStatus.isValidated) {
      emit(state.copyWith(formStatus: FormzStatus.submissionInProgress));
      try {
        await _authRepository.logIn(state.email.value, state.password.value);
        return emit(state.copyWith(formStatus: FormzStatus.submissionSuccess));
      } catch (_) {
        Fluttertoast.showToast(msg: "API error: image size too large (max. 1GB)!", toastLength: Toast.LENGTH_LONG);
        return emit(state.copyWith(formStatus: FormzStatus.submissionFailure));
      }
    }
  }
}
