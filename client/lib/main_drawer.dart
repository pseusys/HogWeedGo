import 'package:flutter/material.dart';

import 'extensions.dart';
import 'map_page.dart';
import 'settings_page.dart';
import 'about_page.dart';


class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text('Drawer Header', style: TextStyle(color: Colors.white, fontSize: 24))
              ),

              ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text("Map"),
                  onTap: () => Navigator.of(context).popAllAndPushNamed(MapPage.route)
              ),

              ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  onTap: () => Navigator.of(context).popAllAndPushNamed(SettingsPage.route)
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

              const ListTile(title: Text("version..."))
            ]
        )
    );
  }
}
