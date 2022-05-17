import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/pages/fullscreen.dart';
import 'package:client/pages/auth.dart';
import 'package:client/navigate/navigator_extension.dart';
import 'package:client/pages/map.dart';
import 'package:client/pages/account.dart';
import 'package:client/pages/about.dart';
import 'package:client/misc/const.dart';
import 'package:client/hogweedgo.dart';
import 'package:client/blocs/account/account_bloc.dart';
import 'package:client/dialogs/auth_dialog.dart';


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
    healthCheck().timeout(const Duration(seconds: 5)).then((value) =>
        setState(() => _connected = value)
    ).onError((error, stackTrace) =>
        setState(() => _connected = false)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              final auth = context.select((AccountBloc bloc) => bloc.state.status);
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

          ListTile(
            title: const Center(child: Text("fullscreen...")),
            onTap: () => Navigator.of(context).pushNamed(FullscreenPage.route, arguments: 'https://i.imgur.com/VuDy0D9.jpg'),
          ),

          ListTile(
            title: const Center(child: Text("auth...")),
            onTap: () => Navigator.of(context).popAllAndPushNamed(AuthPage.route),
          ),
        ],
      ),
    );
  }

  Future<bool> healthCheck() async {
    final response = await get(Uri.parse("${HogWeedGo.server}/healthcheck"));
    return response.statusCode == 200;
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
                _connected == null ? '⚪ Connecting...' : _connected == true ? '🟢 Online' : '🔴 Offline',
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
