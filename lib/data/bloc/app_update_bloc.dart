import 'package:esamudaay_app_update/app_update_service.dart';
import 'package:esamudaay_themes/esamudaay_themes.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/constants/image_path_constants.dart';
import 'package:foore/data/constants/string_constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class EsAppUpdateBloc {
  AppUpdateState esAppUpdateState = new AppUpdateState();

  BehaviorSubject<AppUpdateState> _subjectEsAppUpdateState;

  EsAppUpdateBloc() {
    _subjectEsAppUpdateState =
        new BehaviorSubject<AppUpdateState>.seeded(esAppUpdateState);
  }

  Observable<AppUpdateState> get esAppUpdateStateObservable =>
      _subjectEsAppUpdateState.stream;

  checkForUpdate(BuildContext context) {

    // on app launch, isSelectedLater is false by default.
    // if isSelectedLater is false then show app update prompt to user.
    // if update is not available, showUpdateDialog will return null;
    // otherwise user will have to either update the app or
    // select later (if flexible update is allowed).

    if (!AppUpdateService.isSelectedLater) {
      AppUpdateService.showUpdateDialog(
        context: context,
        title: AppTranslations.of(context).text('app_update_title'),
        message: AppTranslations.of(context).text('app_update_popup_msg'),
        laterButtonText: AppTranslations.of(context).text('app_update_later'),
        updateButtonText: AppTranslations.of(context).text('app_update_action'),
        customThemeData: EsamudaayTheme.of(context),
        packageName: StringConstants.packageName,
        logoImage: Image.asset(
          ImagePathConstants.appLogo,
          height: 42,
          fit: BoxFit.contain,
        ),
      ).then((value) {
        // If user selects later update state variable to true.
        if (AppUpdateService.isSelectedLater) {
          esAppUpdateState.isSelectedLater = true;
          _updateState();
        }
      });
    }
  }

  _updateState() {
    if (!_subjectEsAppUpdateState.isClosed) {
      _subjectEsAppUpdateState.sink.add(esAppUpdateState);
    }
  }

  dispose() {
    _subjectEsAppUpdateState.close();
  }
}

class AppUpdateState {
  bool isSelectedLater;

  AppUpdateState() {
    this.isSelectedLater = AppUpdateService.isSelectedLater ?? false;
  }
}
