import 'package:flutter/material.dart';

import 'extensions.dart';
import 'map_page.dart';
import 'account_page.dart';
import 'about_page.dart';
import 'const.dart';


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
                            backgroundImage: NetworkImage('https://via.placeholder.com/140x100')
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

              const ListTile(
                  title: Center(child: Text("version...")),
                  // onTap: () => Navigator.of(context).popAndPushNamed("ita" + 'https://via.placeholder.com/140x100')
              )
            ]
        )
    );
  }
}
