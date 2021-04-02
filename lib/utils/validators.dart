import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import '../app_translations.dart';
import 'input_limit.dart';

class Validators {
  static String percentageValue(String input, BuildContext context) {
    double percentage = double.tryParse(input);
    if (input == null || input.isEmpty || percentage > 100)
      return AppTranslations.of(context).text("generic_invalid_error");
    return null;
  }

  static String nullValueCheck(String input, BuildContext context) {
    if (input == null || input.isEmpty)
      return AppTranslations.of(context).text("generic_invalid_error");
    return null;
  }

  static String requiredValueCheck(String input, BuildContext context) {
    if (input == null || input.isEmpty)
      return AppTranslations.of(context).text("error_messages_required");
    return null;
  }

  static String validateSkuPrice(String text, BuildContext context) {
    if (double.tryParse(text) == null) {
      return AppTranslations.of(context).text('products_page_invalid_price');
    } else if (double.tryParse(text) < ProductsInputLimit.kSkuPriceMin) {
      return AppTranslations.of(context).text('error_messages_value_too_small');
    } else if (double.tryParse(text) > ProductsInputLimit.kSkuPriceMax) {
      return AppTranslations.of(context).text('error_messages_value_too_big');
    }
    return null;
  }
}
