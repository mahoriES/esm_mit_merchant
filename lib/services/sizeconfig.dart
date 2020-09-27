import 'package:flutter/material.dart';

class SizeConfig {
  SizeConfig._();
  static SizeConfig _instance = SizeConfig._();
  factory SizeConfig() => _instance;

  MediaQueryData _mediaQueryData;
  double screenWidth;
  double screenHeight;
  double devicePixelRatio;
  double refHeight;
  double refWidth;
  double refPixelRatio;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    refHeight = 667;
    refWidth = 375;
  }

  double getWidthRatio(double val) {
    double res = (val / refWidth);
    double temp = res * screenWidth;
    return temp;
  }

  double getHeightRatio(double val) {
    double res = (val / refHeight);
    double temp = res * screenHeight;
    return temp;
  }

  double getFontRatio(double val) {
    double res = (val / refWidth);
    double temp = 0.0;
    if (screenWidth < screenHeight) {
      temp = res * screenWidth;
    } else {
      temp = res * screenHeight;
    }
    return temp;
  }
}

extension SizeUtils on num {
  double get toWidth => SizeConfig().getWidthRatio(this.toDouble());

  double get toHeight => SizeConfig().getHeightRatio(this.toDouble());

  double get toFont => SizeConfig().getFontRatio(this.toDouble());
}
