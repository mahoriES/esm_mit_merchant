import 'package:flutter/material.dart';
import 'package:foore/services/sizeconfig.dart';

class AppColors {

  static const mainColor = Color(0xff4093d1);
  static const darkGrey = Color(0xff989696);
  static const orange = Color(0xffeb730c);
  static const offWhite = Color.fromRGBO(235, 236, 235, 1.0);
  static const green = Color(0xff64ab03);
  static const pureWhite = Color(0xffffffff);
  static const offWhitish = const Color(0xfff0f2f6);
  static const icColors = Color(0xff5f3a9f);
  static const iconColors = Color(0xffd5133a);
  static const separatorColor = Color.fromRGBO(0, 0, 0, 0.2);
  static const blackShadowColor = Color.fromRGBO(0, 0, 0, 0.12);
  static const blackTextColor = Color.fromRGBO(0, 0, 0, 0.87);
  static const greyishText = const Color(0xff808080);
  static const lightBlue = const Color(0xff5091cd);
  static const offGreyish = const Color(0xff515c6f);
  static const hotPink = const Color(0xffe1517d);
  static const appBarColor = Colors.blue;

  static Color get disabledAreaColor => const Color(0xFF969696); // dark grey
  static Color get placeHolderColor => const Color(0xFFe4e4e4); // light grey
}

class _AppFontFamily {
  static const String archivo = "Archivo";
  static const String lato = "Lato";
}

class AppTextStyles {

  static TextStyle get topTileTitle => TextStyle(
        color: AppColors.blackTextColor,
        fontSize: 20.toFont,
        fontWeight: FontWeight.w500,
        fontFamily: _AppFontFamily.archivo,
        height: 1.1,
      );

  static TextStyle get sectionHeading2 => TextStyle(
        color: AppColors.blackTextColor,
        fontSize: 16.toFont,
        fontWeight: FontWeight.w400,
        fontFamily: _AppFontFamily.lato,
        height: 1.18,
      );


  static TextStyle get body1 => TextStyle(
        color: AppColors.blackTextColor,
        fontSize: 12.toFont,
        fontWeight: FontWeight.w400,
        fontFamily: _AppFontFamily.lato,
        height: 1.25,
      );

  static TextStyle get body1Faded => body1.copyWith(
        color: AppColors.disabledAreaColor,
      );

  static TextStyle get body2 => TextStyle(
        color: AppColors.blackTextColor,
        fontSize: 10.toFont,
        fontWeight: FontWeight.w400,
        fontFamily: _AppFontFamily.lato,
        height: 1.2,
      );

  static TextStyle get body2Faded => body2.copyWith(
        color: AppColors.disabledAreaColor,
      );

  static TextStyle get body2Secondary => body2.copyWith(
        color: AppColors.orange,
        fontWeight: FontWeight.bold,
      );

}