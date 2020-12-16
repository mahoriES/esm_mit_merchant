import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/services/validation.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String) onChanged;
  const InputField({
    @required this.hintText,
    @required this.controller,
    this.onChanged,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: ValidationService().validateString,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 0),
        border: UnderlineInputBorder(),
        hintText: hintText,
        hintStyle: AppTextStyles.body1Faded,
      ),
      style: AppTextStyles.body1,
    );
  }
}
