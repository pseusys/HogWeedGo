import 'package:flutter/material.dart';

import 'package:client/pages/fullscreen.dart';
import 'package:client/pages/auth.dart';
import 'package:client/misc/extensions.dart';
import 'package:client/pages/map.dart';
import 'package:client/pages/account.dart';
import 'package:client/pages/about.dart';
import 'package:client/misc/const.dart';


class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                  child: Center(child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const CircleAvatar(
                            radius: picture,
                            backgroundImage: NetworkImage('https://i.imgur.com/koOENqs.jpeg')
                        ),
                        Text('Drawer Header', style: Theme.of(context).primaryTextTheme.headline6)
                      ]
                  ))
              ),

              ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text("Map"),
                  onTap: () => Navigator.of(context).popAllAndPushNamed(MapPage.route)
              ),

              ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text("Account"),
                  onTap: () => Navigator.of(context).popAllAndPushNamed(AccountPage.route)
              ),

              ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("About"),
                  onTap: () => Navigator.of(context).popAllAndPushNamed(AboutPage.route)
              ),

              ListTile(
                  leading: const Icon(Icons.feedback),
                  title: const Text("Feedback"),
                  onTap: () => Navigator.pop(context)
              ),

              ListTile(
                  title: Center(child: Text("version...")),
                  //onTap: () => Navigator.of(context).popAllAndPushNamed(AuthPage.route)
                  onTap: () => Navigator.of(context).pushNamed(FullscreenPage.route + 'https://i.imgur.com/VuDy0D9.jpg')
              )
            ]
        )
    );
  }
}
