import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foore/services/validation.dart';

class CustomInputField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final Function(String) validator;
  final List<TextInputFormatter> format;
  final TextInputType inputType;

  CustomInputField(
    this.labelText,
    this.controller, {
    this.validator,
    this.format,
    this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator ?? ValidationService().validateString,
      inputFormatters: format ?? [],
      keyboardType: inputType ?? null,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: labelText,
      ),
    );
  }
}
