import 'dart:convert';
import 'dart:ui';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_translations_delegate.dart';

class AppTranslationsBloc {
  final AppTranslationsState appTranslationsState = new AppTranslationsState();

  static final List<String> supportedLanguages = [
    "English",
    "हिन्दी (Hindi)",
  ];

  static final List<String> supportedLanguageCodes = [
    "en",
    "hi",
  ];

  //returns the list of supported Locales
  static Iterable<Locale> supportedLocales() =>
      supportedLanguageCodes.map<Locale>((language) => Locale(language));

  BehaviorSubject<AppTranslationsState> _subjectAppTranslationsState;

  AppTranslationsBloc() {
    this._subjectAppTranslationsState =
        new BehaviorSubject<AppTranslationsState>.seeded(appTranslationsState);
    this._loadAuthState();
  }

  Observable<AppTranslationsState> get appTranslationsStateObservable =>
      _subjectAppTranslationsState.stream;

  void onLocaleChanged(Locale locale) async {
    appTranslationsState.localeDelegate =
        AppTranslationsDelegate(newLocale: locale);
    this._updateState();
  }

  _updateState() {
    this._subjectAppTranslationsState.sink.add(this.appTranslationsState);
  }

  dispose() {
    this._subjectAppTranslationsState.close();
  }

  _loadAuthState() async {}

  _storeAppTranslationsState() async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // if (this._appTranslationsState.authData != null) {
    //   await sharedPreferences.setString(
    //       'auth', json.encode(this._appTranslationsState.authData.toJson()));
    // } else {
    //   await sharedPreferences.setString('auth', '');
    // }
  }
}

class AppTranslationsState {
  AppTranslationsDelegate localeDelegate;
  AppTranslationsState() {
    this.localeDelegate = AppTranslationsDelegate();
  }
}
