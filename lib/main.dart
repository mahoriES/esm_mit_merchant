import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations_delegate.dart';
import 'package:foore/crashlytics_delegate.dart';
import 'package:foore/theme/light.dart';
import 'package:foore/utils/navigation_delegate.dart';
import 'package:provider/provider.dart';
import 'data/bloc/analytics.dart';
import 'data/bloc/es_address_bloc.dart';
import 'data/bloc/es_businesses.dart';
import 'data/bloc/login.dart';
import 'data/bloc/onboarding_guard.dart';
import 'package:foore/router.dart';
import 'data/bloc/app_translations_bloc.dart';
import 'data/bloc/auth.dart';
import 'data/http_service.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, //top bar color
    statusBarIconBrightness: Brightness.dark, //top bar icons
  ));

  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() async {
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
          ProxyProvider2<HttpService, AuthBloc, EsBusinessesBloc>(
            builder: (_, http, authBloc, __) =>
                EsBusinessesBloc(http, authBloc),
            dispose: (context, value) => value.dispose(),
          ),
          Provider<AppTranslationsBloc>(
            builder: (context) => AppTranslationsBloc(),
            dispose: (context, value) => value.dispose(),
          ),
          Provider<EsAddressBloc>(
            create: (context) => EsAddressBloc(),
            dispose: (context, value) => value.dispose(),
          ),
        ],
        child: ReviewApp(),
      ),
    );
  }, (Object error, StackTrace stackTrace) {
    debugPrint(
        '********************************************** ${error.toString()}');
    debugPrint('********************************************** $stackTrace');

    /// Whenever an error occurs, call the `recordError` function. This sends
    /// Dart errors to crashlytics
    CrashlyticsDelegate.recordError(error, stackTrace);
  });
}

class ReviewApp extends StatefulWidget {
  ReviewApp({Key key}) : super(key: key);

  _ReviewAppState createState() => _ReviewAppState();
}

class _ReviewAppState extends State<ReviewApp>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<ReviewApp> {
  @override
  void initState() {
    super.initState();
    CrashlyticsDelegate.initializeCrashlytics();
  }

  StreamSubscription<AppTranslationsState> _subscription;

  trackLanguage(AppTranslationsDelegate delegate) async {
    final httpService = Provider.of<HttpService>(context);
    String languageCode = await delegate.getLanguageCode();
    httpService.foAnalytics.addUserProperties(
        name: FoAnalyticsUserProperties.language_chosen,
        value: languageCode != null ? languageCode : 'en');
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final appTranslationsBloc = Provider.of<AppTranslationsBloc>(context);
    _subscription =
        appTranslationsBloc.appTranslationsStateObservable.listen((state) {
      trackLanguage(state.localeDelegate);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTranslationsBloc = Provider.of<AppTranslationsBloc>(context);
    final router = AppRouter(
        httpServiceBloc: Provider.of<HttpService>(context),
        authBloc: Provider.of<AuthBloc>(context),
        esBusinessesBloc: Provider.of<EsBusinessesBloc>(context));

    return StreamBuilder<AppTranslationsState>(
        stream: appTranslationsBloc.appTranslationsStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return MaterialApp(
            title: 'Foore',
            debugShowCheckedModeBanner: false,
            initialRoute: AppRouter.homeRoute,
            onGenerateRoute: router.routeGenerator,
            navigatorKey: NavigationHandler.navigatorKey,
            navigatorObservers: [NavigationHandler.routeObserver],
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
