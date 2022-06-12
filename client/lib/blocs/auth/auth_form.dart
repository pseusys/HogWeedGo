import 'package:formz/formz.dart';


enum EmailValidationError { never }

class Email extends FormzInput<String, EmailValidationError> {
  final String previous;

  const Email.pure(this.previous) : super.pure('');
  const Email.dirty(this.previous, [String value = '']) : super.dirty(value);

  @override
  EmailValidationError? validator(String? value) => null;
}


enum PasswordValidationError { never }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([String value = '']) : super.dirty(value);

  @override
  PasswordValidationError? validator(String? value) => null;
}


enum ConfirmationValidationError { never }

class Confirmation extends FormzInput<String, ConfirmationValidationError> {
  final Password password;

  const Confirmation.pure(this.password) : super.pure('');
  const Confirmation.dirty(this.password, [String value = '']) : super.dirty(value);

  @override
  ConfirmationValidationError? validator(String? value) => null;
}


enum CodeValidationError { never }

class Code extends FormzInput<String, CodeValidationError> {
  const Code.pure() : super.pure('');
  const Code.dirty([String value = '']) : super.dirty(value);

  @override
  CodeValidationError? validator(String? value) => null;
}
