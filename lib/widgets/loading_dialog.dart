import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/utils/navigation_delegate.dart';

// A loading dialog to show on top of any screen.
// It takes the global context.

class LoadingDialog {
  LoadingDialog._();
  static final _instance = LoadingDialog._();
  factory LoadingDialog() => _instance;

  // maintaining this boolean to keep track of whether the screen is already on display.
  static bool isActive = false;

  static show() {
    // If isActive is true then there is no need to show another LoadingDialog.
    if (!isActive) {
      isActive = true;
      showDialog(
        context: NavigationHandler.navigatorKey.currentContext,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => Future.value(false),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                AppColors.pureWhite,
              ),
            ),
          ),
        ),
      );
    }
  }

  static hide() {
    // hide dialog only if LoadingDialog is on display.
    // This makes sure that we do not pop any other screen by mistake.
    if (isActive) {
      isActive = false;
      Navigator.of(NavigationHandler.navigatorKey.currentContext).pop();
    }
  }
}
