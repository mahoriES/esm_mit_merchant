class ValidationService {
  String validateString(String value) {
    if (value.isEmpty) return 'This field is required';
    return null;
  }
}
