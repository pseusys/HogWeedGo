import 'package:bloc/bloc.dart';

import 'package:client/access/account.dart';
import 'package:client/models/user.dart';


abstract class UserEvent {}

class ReloadUserEvent extends UserEvent {}

class NameUserEvent extends UserEvent {
  String name;
  NameUserEvent(this.name);
}

class EmailUserEvent extends UserEvent {
  String email;
  EmailUserEvent(this.email);
}

class UnsetUserEvent extends UserEvent {}


class UserBloc extends Bloc<UserEvent, User?> {
  UserBloc() : super(null) {
    on<ReloadUserEvent>((event, emit) async => emit(await profile()));

    on<NameUserEvent>((event, emit) {
      state?.firstName = event.name;
      emit(state);
    });

    on<EmailUserEvent>((event, emit) {
      state?.email = event.email;
      emit(state);
    });

    on<UnsetUserEvent>((event, emit) => emit(null));
  }
}
