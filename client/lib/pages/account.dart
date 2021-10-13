import 'package:flutter/material.dart';

import 'package:client/views/main_drawer.dart';


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
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),

        body: const Center(),

        drawer: const MainDrawer()
    );
  }
}
