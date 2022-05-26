import 'package:client/blocs/account/account_bloc.dart';
import 'package:client/blocs/account/account_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';

import 'package:client/views/main_drawer.dart';
import 'package:client/misc/const.dart';
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
      if (!_focusNode.hasFocus) context.read<AccountBloc>().add(NameChangeRequested(nameController.text));
    });
  }

  Future<void> validationDialog(BuildContext context, String title, String body, {String option = "Validate", String firstTitle = "", String secondTitle = "", String firstHint = "", String secondHint = "", bool obscure = false, String actionText = "", VoidCallback? addAction, RequestCallback? request}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValidationDialog(title, body, option: option, firstTitle: firstTitle, secondTitle: secondTitle, firstHint: firstHint, secondHint: secondHint, obscure: obscure, actionText: actionText, addAction: addAction, request: request);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select((AccountBloc bloc) => bloc.state.user?.email) ?? "Unknown";
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

                Flexible(
                  child: Column(
                    children: [
                      Flexible(
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

                      const SizedBox(height: MARGIN / 2),

                      Flexible(
                        child: TextField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'User email (current: $email)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: MARGIN),
                ElevatedButton(
                    onPressed: () {},
                    child: const Text("Save")
                ),
              ],
            ),
            const SizedBox(height: MARGIN),

            const SizedBox(height: GAP),
            ElevatedButton(
                onPressed: () {
                  validationDialog(context, "Change your password", "Input your password and retype it again below",
                      firstTitle: "Password",
                      secondTitle: "Confirmation",
                      firstHint: "Enter a valid password!",
                      secondHint: "Password and confirmation do not match!",
                      obscure: true,
                      request: (String password, String confirmation) => context.read<AccountBloc>().add(PasswordChangeRequested(password))
                  );
                },
                child: const Text("Change password")
            ),
            const SizedBox(height: MARGIN),

            Text("Dangerous", style: Theme.of(context).textTheme.headline5),
            const SizedBox(height: GAP),
            ElevatedButton(
              onPressed: () async {
                context.read<AccountBloc>().add(LogoutRequested());
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
                context.read<AccountBloc>().add(LeaveRequested());
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
