import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:foore/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:foore/review_page/reply_gmb.dart';
import 'package:foore/theme/light.dart';
import 'package:foore/unirson_check_in_page/unirosn_check_in_page.dart';
import 'package:provider/provider.dart';
import 'auth_guard/auth_guard.dart';
import 'check_in_page/check_in_page.dart';
import 'data/bloc/app_translations_bloc.dart';
import 'data/bloc/auth.dart';
import 'data/http_service.dart';
import 'data/model/feedback.dart';
import 'data/model/unirson.dart';
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
        Navigator.of(context).pushReplacementNamed(IntroPage.routeName);

    return StreamBuilder<AppTranslationsState>(
        stream: appTranslationsBloc.appTranslationsStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return MaterialApp(
            title: 'Foore',
            home: AuthGuard(
              unauthenticatedHandler: unauthenticatedHandler,
              child: PushNotificationListener(child: HomePage()),
            ),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                      builder: (context) => AuthGuard(
                            unauthenticatedHandler: unauthenticatedHandler,
                            child: PushNotificationListener(child: HomePage()),
                          ));
                  break;
                case IntroPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => IntroPage(),
                  );
                case ReplyGmb.routeName:
                  FeedbackItem feedbackItem = settings.arguments;
                  return MaterialPageRoute(
                    builder: (context) => AuthGuard(
                      unauthenticatedHandler: unauthenticatedHandler,
                      child: ReplyGmb(feedbackItem),
                    ),
                    fullscreenDialog: true,
                  );
                case UnirsonCheckInPage.routeName:
                  UnirsonItem unirsonItem = settings.arguments;
                  return MaterialPageRoute(
                    builder: (context) => AuthGuard(
                      unauthenticatedHandler: unauthenticatedHandler,
                      child: UnirsonCheckInPage(unirsonItem),
                    ),
                    fullscreenDialog: true,
                  );
                case CheckInPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => AuthGuard(
                      unauthenticatedHandler: unauthenticatedHandler,
                      child: CheckInPage(),
                    ),
                    fullscreenDialog: true,
                  );
                  break;
              }
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
