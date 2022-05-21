import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/blocs/account/account_bloc.dart';
import 'package:client/repositories/account_repository.dart';
import 'package:client/hogweedgo.dart';
import 'package:client/blocs/status/status_bloc.dart';
import 'package:client/repositories/status_repository.dart';
import 'package:client/repositories/location_repository.dart';
import 'package:client/blocs/location/location_bloc.dart';


void main() => runApp(
  Root(
    AccountRepository(),
    StatusRepository(),
    LocationRepository(),
  ),
);


class Root extends StatelessWidget {
  const Root(this.accountRepository, this.statusRepository, this.locationRepository, {Key? key}) : super(key: key);

  final AccountRepository accountRepository;
  final StatusRepository statusRepository;
  final LocationRepository locationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: accountRepository),
        RepositoryProvider.value(value: locationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AccountBloc(accountRepository)),
          BlocProvider(create: (_) => StatusBloc(statusRepository)),
          BlocProvider(create: (_) => LocationBloc(locationRepository)),
        ],
        child: HogWeedGo(),
      ),
    );
  }
}
