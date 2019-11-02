import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';
import 'data/bloc/app_translations_bloc.dart';

class AppTranslationsDelegate extends LocalizationsDelegate<AppTranslations> {
  Locale newLocale;
  AppTranslations _appTranslations;

  get currentLanguage =>
      _appTranslations != null ? _appTranslations.currentLanguage : null;

  AppTranslationsDelegate({Locale newLocale}) {
    this.newLocale = newLocale;
    if (newLocale != null) {
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
        this._appTranslations = await AppTranslations.load(Locale(code));
      } else {
        this._appTranslations = await AppTranslations.load(locale);
      }
    } else {
      this._appTranslations = await AppTranslations.load(newLocale);
    }
    return this._appTranslations;
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
