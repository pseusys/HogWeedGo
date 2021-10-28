import 'package:flutter/material.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';

import 'package:client/views/main_drawer.dart';
import 'package:client/misc/const.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  final title = "Account";
  static const route = "/account";

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(title: Text(widget.title)),

        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: MARGIN, horizontal: OFFSET),
          children: [
            Text("Profile", style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: GAP),
            Row(
              children: [
                CircleAvatar(
                    radius: OFFSET * 2,
                    backgroundImage: const NetworkImage('https://i.imgur.com/koOENqs.jpeg'),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            // TODO: change avatar
                          },
                          child: const Icon(Icons.edit),
                        )
                    )
                ),
                const SizedBox(width: MARGIN),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'User name',
                    ),
                    textInputAction: TextInputAction.send,
                  ),
                ),
              ],
            ),
            const SizedBox(height: MARGIN),

            Text("Profile", style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: GAP),
            Row(
              children: [
                const Text("E-mail:"),
                const SizedBox(width: MARGIN),
                Text("user e-mail", style: Theme.of(context).textTheme.headline6),
              ],
            ),
            const SizedBox(height: GAP),
            ElevatedButton(
                onPressed: () {
                  // TODO: change email
                },
                child: const Text("Change email")
            ),
            const SizedBox(height: GAP / 2),
            Text("A verification e-mail will be sent to the address.", style: Theme.of(context).textTheme.caption),
            const SizedBox(height: GAP),
            ElevatedButton(
                onPressed: () {
                  // TODO: change password
                },
                child: const Text("Change password")
            ),
            const SizedBox(height: MARGIN),

            Text("Dangerous", style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: GAP),
            ElevatedButton(
              onPressed: () {
                // TODO: log out
              },
              child: const Text("Log out"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(DANGER),
              ),
            ),
            const SizedBox(height: GAP),
            ElevatedButton(
              onPressed: () {
                // TODO: delete account
              },
              child: const Text("Delete account"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(DANGER),
              ),
            ),
            const SizedBox(height: GAP / 2),
            Text("Your reports will not be deleted.", style: Theme.of(context).textTheme.caption),
          ],
        ),

        drawer: const MainDrawer(),
      ),
    );
  }
}
