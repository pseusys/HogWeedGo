import 'package:flutter/material.dart';

import 'const.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}): super(key: key);

  final String title = "Authentication";
  static const String route = "/auth";

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _noAccount = true;
  bool _createAccount = false;

  String email = "";
  String password = "";

  final TextEditingController _passwordController = TextEditingController();

  Widget _authForm() {
    return Container(
        margin: const EdgeInsets.all(margins),
        child: Form(
            key: _formKey,
            child: Column(
                children: [
                  Text(_noAccount ? "Sign in" : "Log in", style: Theme.of(context).textTheme.headline5),
                  const SizedBox(height: margins / 2),

                  TextFormField(
                      decoration: const InputDecoration(hintText: 'Email'),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter valid email!';
                        } else { return null; }
                      },
                      onSaved: (String? value) => email = value ?? ""
                  ),
                  const SizedBox(height: margins / 2),

                  TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(hintText: 'Password'),
                      autocorrect: false,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter valid password!';
                        } else { return null; }
                      },
                      onSaved: (String? value) => password = value ?? ""
                  ),
                  const SizedBox(height: margins / 2),

                  if (_noAccount) TextFormField(
                      decoration: const InputDecoration(hintText: 'Validation'),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: (String? value) {
                        if (value != _passwordController.text) { return 'Please enter valid password!'; }
                        else { return null; }
                      }
                  ),
                  SizedBox(height: margins / (_noAccount ? 1 : 2)),

                  ElevatedButton(
                    onPressed: (!_noAccount || _createAccount) ? () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // TODO: login!
                      }
                    } : null,
                    child: const Text('Submit'),
                  )
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),

        body: Container(
            margin: const EdgeInsets.symmetric(vertical: margins, horizontal: margins * 2),
            child: Column(
                children: [
                  Text("Become a volunteer!", style: Theme.of(context).textTheme.headline3),

                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () => setState(() => _noAccount = !_noAccount),
                          child: Text(_noAccount ? 'Already have account?' : 'New to HogWeedGo?')
                      ),
                  ),

                  Container(
                      margin: const EdgeInsets.only(top: margins, bottom: margins),
                      child: Card(child: _authForm())
                  ),

                  if (_noAccount) Align(
                      alignment: Alignment.centerRight,
                      child: CheckboxListTile(
                          title: const Text('Animate Slowly'),
                          value: _createAccount,
                          onChanged: (bool? value) => setState(() => _createAccount = value ?? false),
                          controlAffinity: ListTileControlAffinity.leading
                      )
                  )
                ]
            )
        )
    );
  }
}
