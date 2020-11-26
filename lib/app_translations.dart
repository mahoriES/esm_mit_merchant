import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppTranslations {
  Locale locale;
  static Map<dynamic, dynamic> _localizedValues;

  // When some keys are not found in the translations json we want to show from the fallback
  static Map<dynamic, dynamic> _localizedFallbackValues;
  // English as fallback
  static const String _fallBackLanguageCode = 'en';

  AppTranslations(Locale locale) {
    this.locale = locale;
  }

  static AppTranslations of(BuildContext context) {
    return Localizations.of<AppTranslations>(context, AppTranslations);
  }

  static Future<void> _loadFallback() async {
    if (_localizedFallbackValues == null) {
      String jsonContent = await rootBundle
          .loadString("assets/locale/localization_$_fallBackLanguageCode.json");
      _localizedFallbackValues = json.decode(jsonContent);
    }
  }

  static Future<AppTranslations> load(Locale locale) async {
    AppTranslations appTranslations = AppTranslations(locale);
    await _loadFallback();
    String jsonContent = await rootBundle
        .loadString("assets/locale/localization_${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);
    return appTranslations;
  }

  get currentLanguage => locale.languageCode;

  String text(String key) {
    return _localizedValues[key] ?? _localizedFallbackValues[key] ?? '$key';
  }
}
