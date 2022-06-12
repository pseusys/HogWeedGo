import 'package:client/models/user.dart';


class AuthState {
  static const DEFAULT_NAME = "Anonymous";

  final String? token;
  final String _name;
  final User? user;

  bool get status => token != null;
  String get name => _name;

  const AuthState(this.token, this.user, this._name);
  const AuthState.out(): token = null, user = null, _name = DEFAULT_NAME;

  static String _getName(User? user, String? fallback) {
    if (user != null && user.firstName != null) return user.firstName!;
    if (fallback != null) return fallback;
    return DEFAULT_NAME;
  }

  AuthState copyWith({String? token, User? user, String? email}) => AuthState(
    token ?? this.token,
    user ?? this.user,
    _getName(user ?? this.user, email ?? _name),
  );
}
