import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foore/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:foore/theme/light.dart';
import 'package:provider/provider.dart';
import 'auth_guard/auth_guard.dart';
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
    final appTranslationsBloc = Provider.of<AppTranslationsBloc>(context);
    final unauthenticatedHandler = (BuildContext context) =>
        Navigator.of(context).pushReplacementNamed('/intro');

    return StreamBuilder<AppTranslationsState>(
        stream: appTranslationsBloc.appTranslationsStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return MaterialApp(
            title: 'Foore',
            initialRoute: '/',
            routes: {
              '/': (context) => AuthGuard(
                    unauthenticatedHandler: unauthenticatedHandler,
                    child: PushNotificationListener(child: HomePage()),
                  ),
              '/intro': (context) => IntroPage(),
            },
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
