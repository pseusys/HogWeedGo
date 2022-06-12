import 'package:formz/formz.dart';

import 'package:client/blocs/auth/auth_form.dart';
import 'package:client/blocs/login/login_form.dart';


class LoginState {
  final FormzStatus formStatus;
  final FormzStatus codeStatus;
  final Email email;
  final Password password;
  final Confirmation confirmation;
  final Code code;
  final Policy policy;
  final bool newAccount;

  const LoginState({
    this.formStatus = FormzStatus.pure,
    this.codeStatus = FormzStatus.pure,
    this.email = const Email.pure(""),
    this.password = const Password.pure(),
    this.confirmation = const Confirmation.pure(Password.pure()),
    this.code = const Code.pure(),
    this.policy = const Policy.pure(),
    this.newAccount = false,
  });

  LoginState copyWith({FormzStatus? formStatus, FormzStatus? codeStatus, Email? email, Password? password, Confirmation? confirmation, Code? code, Policy? policy, bool? newAccount}) => LoginState(
    formStatus: formStatus ?? this.formStatus,
    codeStatus: codeStatus ?? this.codeStatus,
    email: email ?? this.email,
    password: password ?? this.password,
    confirmation: confirmation ?? this.confirmation,
    code: code ?? this.code,
    policy: policy ?? this.policy,
    newAccount: newAccount ?? this.newAccount,
  );
}
