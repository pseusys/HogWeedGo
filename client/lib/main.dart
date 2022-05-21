import 'package:client/blocs/location/location_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/blocs/account/account_bloc.dart';
import 'package:client/repositories/account_repository.dart';
import 'package:client/hogweedgo.dart';
import 'package:client/blocs/reports/reports_bloc.dart';
import 'package:client/blocs/view/view_bloc.dart';
import 'package:client/repositories/api_repository.dart';
import 'package:client/repositories/location_repository.dart';


void main() => runApp(
  Root(
    AccountRepository(),
    ApiRepository(),
    LocationRepository(),
  ),
);


class Root extends StatelessWidget {
  const Root(this.accountRepository, this.apiRepository, this.locationRepository, {Key? key}) : super(key: key);

  final AccountRepository accountRepository;
  final ApiRepository apiRepository;
  final LocationRepository locationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: accountRepository),
        RepositoryProvider.value(value: apiRepository),
        RepositoryProvider.value(value: locationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AccountBloc(accountRepository)),
          BlocProvider(create: (_) => ReportsBloc(apiRepository)),
          BlocProvider(create: (_) => ViewBloc(apiRepository, accountRepository)),
          BlocProvider(create: (_) => LocationBloc(locationRepository)),
        ],
        child: HogWeedGo(),
      ),
    );
  }
}
