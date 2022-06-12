import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';


enum NameValidationError { never }

class Name extends FormzInput<String, NameValidationError> {
  final String previous;

  const Name.pure(this.previous) : super.pure('');
  const Name.dirty(this.previous, [String value = '']) : super.dirty(value);

  @override
  NameValidationError? validator(String? value) => null;
}


enum ImageValidationError { never }

class Image extends FormzInput<XFile?, ImageValidationError> {
  const Image.pure() : super.pure(null);
  const Image.dirty(XFile? value) : super.dirty(value);

  @override
  ImageValidationError? validator(XFile? value) => null;
}
