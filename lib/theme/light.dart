import 'package:flutter/material.dart';

class FooreLightTheme {
  static ThemeData get themeData {
    final primaryColor = Colors.blue;
    final appBackground = Colors.white;
    final ThemeData base = ThemeData.light();
    final TextTheme baseTextTheme = _buildFooreTextTheme(base.textTheme);
    return base.copyWith(
      primaryColor: primaryColor,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
        colorScheme: ColorScheme.light().copyWith(
          primary: primaryColor,
        ),
      ),
      scaffoldBackgroundColor: appBackground,
      textTheme: baseTextTheme,
      accentColor: Colors.blueAccent,
      dividerColor: Color.fromRGBO(233, 233, 233, 0.50),
      appBarTheme: _buildFooreAppBarTheme(base.appBarTheme),
    );
  }

  static TextTheme _buildFooreTextTheme(TextTheme base) {
    return base
        .copyWith(
          subtitle: base.subtitle.copyWith(
            color: Colors.black54,
          ),
        )
        .apply(
          fontFamily: 'Lato',
        );
  }

  static AppBarTheme _buildFooreAppBarTheme(AppBarTheme base) {
    return base.copyWith(
      color: Colors.white,
      brightness: Brightness.light,
      elevation: 0.0,
      iconTheme: IconThemeData.fallback(),
      textTheme: Typography.englishLike2018.copyWith(
        title: Typography.englishLike2018.title.copyWith(
          fontFamily: 'Lato',
          color: Colors.black87,
        ),
      ),
    );
  }
}
