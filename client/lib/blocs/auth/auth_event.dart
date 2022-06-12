import 'package:client/models/user.dart';


abstract class AuthEvent {
  const AuthEvent();
}

class TokenChanged extends AuthEvent {
  final String? token;
  const TokenChanged(this.token);
}

class EmailChanged extends AuthEvent {
  final String? email;
  const EmailChanged(this.email);
}

class UserChanged extends AuthEvent {
  final User? user;
  const UserChanged(this.user);
}
