import 'package:image_picker/image_picker.dart';

import 'package:client/models/user.dart';


abstract class LoginEvent {
  const LoginEvent();
}

class EmailChanged extends LoginEvent {
  final String email;
  const EmailChanged(this.email);
}

class CodeChanged extends LoginEvent {
  final String code;
  const CodeChanged(this.code);
}

class PasswordChanged extends LoginEvent {
  final String password;
  const PasswordChanged(this.password);
}

class ConfirmationChanged extends LoginEvent {
  final String confirmation;
  const ConfirmationChanged(this.confirmation);
}

class PolicyChanged extends LoginEvent {
  final bool accepted;
  const PolicyChanged(this.accepted);
}

class ModeChanged extends LoginEvent {
  final bool newAccount;
  const ModeChanged(this.newAccount);
}

class FormSubmitted extends LoginEvent {}

class CodeSubmitted extends LoginEvent {}
