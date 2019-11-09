import 'package:flutter/material.dart';

class FooreDarkTheme {
  static ThemeData get themeData {
    final primaryColor = Colors.blue;
    final appBackground = Colors.black;
    final ThemeData base = ThemeData.dark();
    final TextTheme baseTextTheme = _buildFooreTextTheme(base.textTheme);
    return base.copyWith(
      primaryColor: primaryColor,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
        colorScheme: ColorScheme.dark().copyWith(
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
            color: Colors.white54,
          ),
        )
        .apply(
          fontFamily: 'Lato',
        );
  }

  static AppBarTheme _buildFooreAppBarTheme(AppBarTheme base) {
    return base.copyWith(
      color: Colors.black,
      brightness: Brightness.dark,
      elevation: 0.0,
      iconTheme: IconThemeData.fallback().copyWith(color: Colors.white60),
      textTheme: Typography.englishLike2018.copyWith(
        title: Typography.englishLike2018.title.copyWith(
          fontFamily: 'Lato',
          color: Colors.white60,
        ),
      ),
    );
  }
}