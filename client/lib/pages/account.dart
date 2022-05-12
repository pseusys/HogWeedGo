import 'package:flutter/material.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';

import 'package:client/views/main_drawer.dart';
import 'package:client/misc/const.dart';
import 'package:client/access/account.dart';
import 'package:client/views/base_dialogs.dart';
import 'package:client/navigate/navigator_extension.dart';
import 'package:client/pages/map.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  final title = "Account";
  static const route = "/account";

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _focusNode = FocusNode();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) setup();
    });
  }

  Future<bool> validationDialog(BuildContext context, String title, String body, {String option = "Validate", String firstTitle = "", String secondTitle = "", String firstHint = "", String secondHint = "", bool obscure = false, String actionText = "", AsyncVoidCallback? addAction, AsyncBoolCallback? request}) async {
    final action = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValidationDialog(title, body, option: option, firstTitle: firstTitle, secondTitle: secondTitle, firstHint: firstHint, secondHint: secondHint, obscure: obscure, actionText: actionText, addAction: addAction, request: request);
      },
    );
    return (action != null) ? action : false;
  }

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
                    ),
                  ),
                ),

                const SizedBox(width: MARGIN),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'User name',
                    ),
                    textInputAction: TextInputAction.send,
                    focusNode: _focusNode,
                    controller: nameController,
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
                  validationDialog(context, "Change your email", "Input your email, click 'Send code' and input the code below",
                    firstTitle: "Email",
                    secondTitle: "Code",
                    firstHint: "Enter a valid email!",
                    secondHint: "Enter a valid 8-digit code!",
                    actionText: "Send code",
                    addAction: (String email) => proveEmail(email),
                    request: (String email, String code) => setup(email: email, code: code)
                  );
                },
                child: const Text("Change email")
            ),
            const SizedBox(height: GAP / 2),
            Text("A verification e-mail will be sent to the address.", style: Theme.of(context).textTheme.caption),
            const SizedBox(height: GAP),
            ElevatedButton(
                onPressed: () {
                  validationDialog(context, "Change your password", "Input your password and retype it again below",
                      firstTitle: "Password",
                      secondTitle: "Confirmation",
                      firstHint: "Enter a valid password!",
                      secondHint: "Password and confirmation do not match!",
                      obscure: true,
                      request: (String password, String confirmation) => setup(password: password)
                  );
                },
                child: const Text("Change password")
            ),
            const SizedBox(height: MARGIN),

            Text("Dangerous", style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: GAP),
            ElevatedButton(
              onPressed: () async {
                await logOut();
                Navigator.of(context, rootNavigator: true).popAllAndPushNamed(MapPage.route);
              },
              child: const Text("Log out"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(DANGER),
              ),
            ),
            const SizedBox(height: GAP),
            ElevatedButton(
              onPressed: () async {
                await leave();
                Navigator.of(context, rootNavigator: true).popAllAndPushNamed(MapPage.route);
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

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
