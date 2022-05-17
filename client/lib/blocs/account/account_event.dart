abstract class AccountEvent {
  const AccountEvent();
}

class StatusChanged extends AccountEvent {
  const StatusChanged(this.status);
  final bool status;
}

class AuthenticationRequested extends AccountEvent {
  const AuthenticationRequested(this.email, this.password, this.code);
  final String email, password, code;
}

class LoginRequested extends AccountEvent {
  const LoginRequested(this.email, this.password);
  final String email, password;
}

class EmailProveRequested extends AccountEvent {
  const EmailProveRequested(this.email);
  final String email;
}

class NameChangeRequested extends AccountEvent {
  const NameChangeRequested(this.name);
  final String name;
}

class EmailChangeRequested extends AccountEvent {
  const EmailChangeRequested(this.email, this.code);
  final String email, code;
}

class PasswordChangeRequested extends AccountEvent {
  const PasswordChangeRequested(this.password);
  final String password;
}

class LogoutRequested extends AccountEvent {}

class LeaveRequested extends AccountEvent {}
