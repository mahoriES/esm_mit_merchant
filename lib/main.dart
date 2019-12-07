import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:foore/theme/light.dart';
import 'package:provider/provider.dart';
import 'data/bloc/login.dart';
import 'data/bloc/onboarding_guard.dart';
import 'router.dart';
import 'data/bloc/app_translations_bloc.dart';
import 'data/bloc/auth.dart';
import 'data/http_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, //top bar color
    statusBarIconBrightness: Brightness.dark, //top bar icons
  ));
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runZoned<Future<void>>(() async {
    runApp(
      MultiProvider(
        providers: [
          Provider<AuthBloc>(
            builder: (context) => AuthBloc(),
            dispose: (context, value) => value.dispose(),
          ),
          ProxyProvider<AuthBloc, HttpService>(
            builder: (_, authBloc, __) => HttpService(authBloc),
          ),
          ProxyProvider2<HttpService, AuthBloc, LoginBloc>(
            builder: (_, httpService, authBloc, __) =>
                LoginBloc(httpService, authBloc),
          ),
          ProxyProvider<HttpService, OnboardingGuardBloc>(
            builder: (_, http, __) => OnboardingGuardBloc(http),
            dispose: (context, value) => value.dispose(),
          ),
          Provider<AppTranslationsBloc>(
            builder: (context) => AppTranslationsBloc(),
            dispose: (context, value) => value.dispose(),
          ),
        ],
        child: ReviewApp(),
      ),
    );
  }, onError: Crashlytics.instance.recordError);
}

class ReviewApp extends StatefulWidget {
  ReviewApp({Key key}) : super(key: key);

  _ReviewAppState createState() => _ReviewAppState();
}

class _ReviewAppState extends State<ReviewApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appTranslationsBloc = Provider.of<AppTranslationsBloc>(context);
    final router = Router(
      httpServiceBloc: Provider.of<HttpService>(context),
      authBloc: Provider.of<AuthBloc>(context),
    );

    return StreamBuilder<AppTranslationsState>(
        stream: appTranslationsBloc.appTranslationsStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return MaterialApp(
            title: 'Foore',
            initialRoute: Router.homeRoute,
            onGenerateRoute: router.routeGenerator,
            localizationsDelegates: [
              snapshot.data.localeDelegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppTranslationsBloc.supportedLocales(),
            theme: FooreLightTheme.themeData,
          );
        });
  }
}
