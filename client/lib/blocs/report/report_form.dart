import 'package:formz/formz.dart';

import 'package:client/misc/pair.dart';


enum AddressValidationError { never }

class Address extends FormzInput<String, AddressValidationError> {
  const Address.pure() : super.pure('');
  const Address.dirty([String value = '']) : super.dirty(value);

  @override
  AddressValidationError? validator(String? value) => null;
}


enum CommentValidationError { empty }

class Comment extends FormzInput<String, CommentValidationError> {
  const Comment.pure() : super.pure('');
  const Comment.dirty([String value = '']) : super.dirty(value);

  @override
  CommentValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : CommentValidationError.empty;
  }
}


enum ImageValidationError { empty, uncertain }

class Image extends FormzInput<Pair<String, int>, ImageValidationError> {
  Image.pure() : super.pure(const Pair('', 100));
  Image.dirty([String value = '']) : super.dirty(Pair(value, 100));

  @override
  ImageValidationError? validator(Pair<String, int>? value) {
    if (value?.first.isEmpty == true) return ImageValidationError.empty;
    if (value?.second != null && value!.second < 50) return ImageValidationError.uncertain;
    return null;
  }
}
