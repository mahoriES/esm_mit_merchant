import 'dart:ui';
import 'package:rxdart/rxdart.dart';

import '../../app_translations_delegate.dart';

class AppTranslationsBloc {
  final AppTranslationsState appTranslationsState = new AppTranslationsState();

  static final List<String> supportedLanguages = [
    "English",
    "हिन्दी (Hindi)",
    // "मराठी (Marathi)",
    // "ગુજરાતી (Gujarati)",
    // "ਪੰਜਾਬੀ (Punjabi)",
    "தமிழ் (Tamil)",
    // "മലയാളം (Malayalam)",
    "తెలుగు (Telugu)",
    "ಕನ್ನಡ (Kannada)"
  ];

  static final List<String> supportedLanguageCodes = [
    "en",
    "hi",
    // "mr",
    // "gu",
    // "pa",
    "ta",
    // "ml",
    "te",
    "kn"
  ];

  //returns the list of supported Locales
  static Iterable<Locale> supportedLocales() =>
      supportedLanguageCodes.map<Locale>((language) => Locale(language));

  BehaviorSubject<AppTranslationsState> _subjectAppTranslationsState;

  AppTranslationsBloc() {
    this._subjectAppTranslationsState =
        new BehaviorSubject<AppTranslationsState>.seeded(appTranslationsState);
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
}

class AppTranslationsState {
  AppTranslationsDelegate localeDelegate;
  AppTranslationsState() {
    this.localeDelegate = AppTranslationsDelegate();
  }
}
