import 'package:client/access/account.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:client/misc/const.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}): super(key: key);

  final title = "Authentication";
  static const route = "/auth";

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var _noAccount = true;
  var _createAccount = false;

  var email = "";
  var password = "";

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _showCodeConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm your email'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Enter the 8-digit confirmation code (sent to your email address)'),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'Confirmation code'),
                  controller: _codeController,
                  autocorrect: false,
                  validator: (String? value) {
                    if (value == null || value.isEmpty || value.length < 8) {
                      return 'Please enter valid code!';
                    } else { return null; }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                final text = _codeController.text;
                if (text.isEmpty || text.length < 8) {
                  print("object");
                } else {
                  Navigator.of(context).pop();
                  authenticate(email, password, _codeController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _authForm() {
    return Container(
      margin: const EdgeInsets.all(MARGIN),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(_noAccount ? "Sign in" : "Log in", style: Theme.of(context).textTheme.headline5),

            TextFormField(
              decoration: const InputDecoration(hintText: 'Email'),
              autocorrect: false,
              initialValue: email,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter valid email!';
                } else { return null; }
              },
              onSaved: (String? value) => email = value ?? "",
            ),

            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter valid password!';
                } else { return null; }
              },
              onSaved: (String? value) => password = value ?? "",
            ),

            if (_noAccount) TextFormField(
              decoration: const InputDecoration(hintText: 'Validation'),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (String? value) {
                if (value != _passwordController.text) { return 'Please enter valid password!'; }
                else { return null; }
              },
            ),
            SizedBox(height: _noAccount ? MARGIN : GAP),

            ElevatedButton(
              onPressed: (!_noAccount || _createAccount) ? () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (_noAccount) { _showCodeConfirmationDialog(); }
                  else { logIn(email, password); }
                }
              } : null,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
        ),

        body: Container(
          margin: const EdgeInsets.symmetric(vertical: MARGIN, horizontal: OFFSET),
          child: Column(
            children: [
              Text("Become a volunteer!", style: Theme.of(context).textTheme.headline3),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _noAccount = !_noAccount),
                  child: Text(_noAccount ? 'Already have account?' : 'New to HogWeedGo?'),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: MARGIN, bottom: MARGIN),
                child: Card(child: _authForm()),
              ),

              if (_noAccount) Align(
                alignment: Alignment.centerRight,
                child: ListTile(
                  leading: Checkbox(
                    value: _createAccount,
                    onChanged: (bool? value) => setState(() => _createAccount = value ?? false),
                  ),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Agree to ',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        TextSpan(
                          text: 'terms',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launch('https://docs.flutter.io/flutter/services/UrlLauncher-class.html'),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        TextSpan(
                          text: 'conditions',
                          style: const TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launch('https://docs.flutter.io/flutter/services/UrlLauncher-class.html'),
                        ),
                        TextSpan(
                          text: '.',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
