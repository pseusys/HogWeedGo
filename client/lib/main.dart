import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/blocs/account/account_bloc.dart';
import 'package:client/repositories/account_repository.dart';
import 'package:client/hogweedgo.dart';


void main() => runApp(
  Root(
    AccountRepository(),
  ),
);


class Root extends StatelessWidget {
  const Root(this.accountRepository, {Key? key}) : super(key: key);

  final AccountRepository accountRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: accountRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AccountBloc(accountRepository)),
        ],
        child: HogWeedGo(),
      ),
    );
  }
}
