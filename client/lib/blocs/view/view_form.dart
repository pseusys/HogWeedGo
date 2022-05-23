import 'package:formz/formz.dart';

import 'package:client/misc/pair.dart';


enum CommentValidationError { empty }

class Note extends FormzInput<String, CommentValidationError> {
  const Note.pure() : super.pure('');
  const Note.dirty([String value = '']) : super.dirty(value);

  @override
  CommentValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : CommentValidationError.empty;
  }
}
