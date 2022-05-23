import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';

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


enum ImageValidationError { uncertain }

class Image extends FormzInput<Pair<XFile, int>, ImageValidationError> {
  Image.dirty(XFile value) : super.dirty(Pair(value, 100));

  @override
  ImageValidationError? validator(Pair<XFile, int>? value) {
    if (value?.second != null && value!.second < 50) return ImageValidationError.uncertain;
    return null;
  }
}
