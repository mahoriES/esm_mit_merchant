import 'package:foore/logo_page/logo_page.dart';
import 'package:foore/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/bloc/auth.dart';
import 'data/http_service.dart';
import 'data/push_notification_listener.dart';
import 'login_page/login_page.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          Provider<AuthBloc>(
              builder: (context) => AuthBloc(),
              dispose: (context, value) => value.dispose()),
          ProxyProvider<AuthBloc, HttpService>(
            builder: (_, authBloc, __) => HttpService(authBloc),
          ),
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
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          elevation: 0.5,
        ),
      ),
      home: StreamBuilder<AuthState>(
          stream: authBloc.authStateObservable,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isLoading) {
                return LogoPage();
              } else if (snapshot.data.isLoadingFailed) {
                return LoginPage();
              } else if (snapshot.data.isLoggedIn) {
                return PushNotificationListener(child: HomePage());
              } else {
                return LoginPage();
              }
            }
            return Container();
          }),
    );
  }
}
