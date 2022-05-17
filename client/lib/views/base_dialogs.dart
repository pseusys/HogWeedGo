import 'package:flutter/material.dart';

import 'package:client/navigate/navigator_extension.dart';


typedef RequestCallback = void Function(String, String);
typedef VoidCallback = void Function(String);


class YesOrNoDialog extends StatelessWidget {
  final String title, body, yesOption, noOption, yesDestination, noDestination;

  const YesOrNoDialog(this.title, this.body, {Key? key, this.yesOption = "Yes", this.noOption = "No", this.yesDestination = "", this.noDestination = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (noDestination != "") {
              Navigator.of(context, rootNavigator: true).popAllAndPushNamed(noDestination);
            } else {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          child: Text(noOption),
        ),
        TextButton(
          onPressed: () {
            if (yesDestination != "") {
              Navigator.of(context, rootNavigator: true).popAllAndPushNamed(yesDestination);
            } else {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          child: Text(yesOption),
        ),
      ],
    );
  }
}


class ValidationDialog extends StatelessWidget {
  final String title, body, option, firstTitle, secondTitle, firstHint, secondHint, actionText;
  final bool obscure;
  final VoidCallback? addAction;
  final RequestCallback? request;

  const ValidationDialog(this.title, this.body, {Key? key, this.option = "Validate", this.firstTitle = "", this.secondTitle = "", this.firstHint = "", this.secondHint = "", this.obscure = false, this.actionText = "", this.addAction, this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController firstController = TextEditingController();
    String firstValue = "", secondValue = "";
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(hintText: firstTitle),
              controller: firstController,
              obscureText: obscure,
              enableSuggestions: obscure,
              autocorrect: false,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return firstHint;
                } else { return null; }
              },
              onSaved: (String? value) => firstValue = value ?? "",
            ),

            if (addAction != null) TextButton(
              onPressed: () => addAction!.call(firstController.text),
              child: Text(actionText),
            ),

            TextFormField(
              decoration: InputDecoration(hintText: firstTitle),
              obscureText: obscure,
              enableSuggestions: obscure,
              autocorrect: false,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return firstHint;
                } else { return null; }
              },
              onSaved: (String? value) => secondValue = value ?? "",
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              request?.call(firstValue, secondValue);
              Navigator.of(context).pop();
            }
          },
          child: Text(option),
        ),
      ],
    );
  }
}
