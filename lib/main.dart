import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foore/logo_page/logo_page.dart';
import 'package:foore/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:foore/theme/dark.dart';
import 'package:foore/theme/light.dart';
import 'package:provider/provider.dart';
import 'data/bloc/app_translations_bloc.dart';
import 'data/bloc/auth.dart';
import 'data/http_service.dart';
import 'data/push_notification_listener.dart';
import 'intro_page/intro_page.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          Provider<AuthBloc>(
              builder: (context) => AuthBloc(),
              dispose: (context, value) => value.dispose()),
          ProxyProvider<AuthBloc, HttpService>(
            builder: (_, authBloc, __) => HttpService(authBloc),
          ),
          Provider<AppTranslationsBloc>(
              builder: (context) => AppTranslationsBloc(),
              dispose: (context, value) => value.dispose()),
        ],
        child: ReviewApp(),
      ),
    );

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
    final authBloc = Provider.of<AuthBloc>(context);
    final appTranslationsBloc = Provider.of<AppTranslationsBloc>(context);

    return StreamBuilder<AppTranslationsState>(
        stream: appTranslationsBloc.appTranslationsStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return MaterialApp(
            title: 'Foore',
            theme: FooreDarkTheme.themeData,
            home: StreamBuilder<AuthState>(
                stream: authBloc.authStateObservable,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.isLoading) {
                      return LogoPage();
                    } else if (snapshot.data.isLoadingFailed) {
                      return IntroPage();
                    } else if (snapshot.data.isLoggedIn) {
                      return PushNotificationListener(child: HomePage());
                    } else {
                      return IntroPage();
                    }
                  }
                  return Container();
                }),
            localizationsDelegates: [
              snapshot.data.localeDelegate,
              //provides localized strings
              GlobalMaterialLocalizations.delegate,
              //provides RTL support
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppTranslationsBloc.supportedLocales(),
          );
        });
  }
}
