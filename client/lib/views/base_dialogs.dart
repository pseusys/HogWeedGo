import 'package:flutter/material.dart';

typedef AsyncBoolCallback = Future<bool> Function(String, String);
typedef AsyncVoidCallback = Future<void> Function(String);

Future<bool> yesOrNoDialog(BuildContext context, String title, String body, {String yesOption = "Yes", String noOption = "No"}) async {
  final action = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(noOption),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(yesOption,
              style: const TextStyle(
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      );
    },
  );
  return (action != null) ? action : false;
}

Future<bool> validationDialog(BuildContext context, String title, String body, {String option = "Validate", String firstTitle = "", String secondTitle = "", String firstHint = "", String secondHint = "", bool obscure = false, String actionText = "", AsyncVoidCallback? addAction, AsyncBoolCallback? request}) async {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstController = TextEditingController();
  String firstValue = "", secondValue = "";

  final action = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Form(
          key: formKey,
          child: Column(
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
                onPressed: () => addAction.call(firstController.text),
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
                final result = await request?.call(firstValue, secondValue) ?? true;
                Navigator.of(context).pop(result);
              }
            },
            child: Text(option),
          ),
        ],
      );
    },
  );
  return (action != null) ? action : false;
}
