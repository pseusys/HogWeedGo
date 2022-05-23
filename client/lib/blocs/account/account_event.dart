abstract class AccountEvent {
  const AccountEvent();
}

class StatusChanged extends AccountEvent {
  final bool status;
  const StatusChanged(this.status);
}

class AuthenticationRequested extends AccountEvent {
  final String email, password, code;
  const AuthenticationRequested(this.email, this.password, this.code);
}

class LoginRequested extends AccountEvent {
  final String email, password;
  const LoginRequested(this.email, this.password);
}

class EmailProveRequested extends AccountEvent {
  final String email;
  const EmailProveRequested(this.email);
}

class NameChangeRequested extends AccountEvent {
  final String name;
  const NameChangeRequested(this.name);
}

class EmailChangeRequested extends AccountEvent {
  final String email, code;
  const EmailChangeRequested(this.email, this.code);
}

class PasswordChangeRequested extends AccountEvent {
  final String password;
  const PasswordChangeRequested(this.password);
}

class LogoutRequested extends AccountEvent {}

class LeaveRequested extends AccountEvent {}
