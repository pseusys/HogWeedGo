import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/navigate/navigator_extension.dart';
import 'package:client/pages/map.dart';
import 'package:client/pages/account.dart';
import 'package:client/pages/about.dart';
import 'package:client/misc/const.dart';
import 'package:client/blocs/account/account_bloc.dart';
import 'package:client/dialogs/auth_dialog.dart';
import 'package:client/blocs/status/status_bloc.dart';
import 'package:client/blocs/status/status_state.dart';


class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key}): super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  bool? _connected;

  @override
  void initState() {
    super.initState();
    // TODO: add to network state change listener.
    _connected = context.select((StatusBloc bloc) => bloc.state.status);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.select((AccountBloc bloc) => bloc.state.status);
    return BlocListener<StatusBloc, StatusState>(
      listener: (context, state) => setState(() => _connected = state.status),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _MainDrawerHeader(_connected),

            ListTile(
              leading: const Icon(Icons.map),
              title: const Text("Map"),
              onTap: () => Navigator.of(context).popAllAndPushNamed(MapPage.route),
            ),

            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Account"),
              onTap: () async {
                if (auth) {
                  Navigator.of(context).popAllAndPushNamed(AccountPage.route);
                } else {
                  Navigator.of(context).pushNamed(AuthDialog.route);
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () => Navigator.of(context).popAllAndPushNamed(AboutPage.route),
            ),

            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}


class _MainDrawerHeader extends StatelessWidget {
  final bool? _connected;

  const _MainDrawerHeader(this._connected, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: GAP),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const CircleAvatar(
                radius: OFFSET,
                backgroundImage: NetworkImage('https://i.imgur.com/koOENqs.jpeg'),
              ),
              Text('Drawer Header', style: Theme.of(context).primaryTextTheme.headline6),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _connected == null ? '⚪ Connecting...' : (_connected == true ? '🟢 Online' : '🔴 Offline'),
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
