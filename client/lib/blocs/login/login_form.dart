import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';


enum PolicyValidationError { never }

class Policy extends FormzInput<bool, PolicyValidationError> {
  const Policy.pure() : super.pure(false);
  const Policy.dirty(bool value) : super.dirty(value);

  @override
  PolicyValidationError? validator(bool? value) => null;
}
