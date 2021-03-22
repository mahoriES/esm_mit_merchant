import 'package:flutter/material.dart';

import '../app_translations.dart';

validateSkuPrice(String text, BuildContext context) {
  if (double.tryParse(text) == null) {
    return AppTranslations.of(context).text('products_page_invalid_price');
  }
}
