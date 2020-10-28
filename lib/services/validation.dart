class ValidationService {
  String validateString(String value) {
    if (value.isEmpty) return 'This field is required';
    return null;
  }

  String validateDouble(String value) {
    if (value.isEmpty) return 'This field is required';
    if (double.tryParse(value) == null) return 'Input value should be a number';
    return null;
  }

  String validateInt(String value) {
    if (value.isEmpty) return 'This field is required';
    if (int.tryParse(value) == null) return 'Input value should be an integer';
    return null;
  }
}
