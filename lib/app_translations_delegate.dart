import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';
import 'data/bloc/app_translations_bloc.dart';

class AppTranslationsDelegate extends LocalizationsDelegate<AppTranslations> {
  Locale newLocale;

  AppTranslationsDelegate({Locale newLocale}) {
    this.newLocale = newLocale;
    if (newLocale != null) {
      print(newLocale.languageCode);
      storeLanguageCode(newLocale.languageCode);
    }
  }

  @override
  bool isSupported(Locale locale) {
    return AppTranslationsBloc.supportedLanguageCodes
        .contains(locale.languageCode);
  }

  @override
  Future<AppTranslations> load(Locale locale) async {
    if (newLocale == null) {
      var code = await getLanguageCode();
      if (code != null) {
        return await AppTranslations.load(Locale(code));
      } else {
        return await AppTranslations.load(locale);
      }
    } else {
      return await AppTranslations.load(newLocale);
    }
  }

  storeLanguageCode(String languageCode) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('language_code', languageCode);
  }

  Future<String> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code') ?? null;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppTranslations> old) {
    return true;
  }
}
