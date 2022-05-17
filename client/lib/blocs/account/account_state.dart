import 'package:client/models/user.dart';


class AccountState {
  final bool status;
  final User? user;

  const AccountState._(this.status, {this.user});

  const AccountState.authenticated(User user) : this._(true, user: user);

  const AccountState.unauthenticated() : this._(false);
}
