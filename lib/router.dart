import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth_guard/auth_guard.dart';
import 'check_in_page/check_in_page.dart';
import 'data/model/feedback.dart';
import 'data/model/unirson.dart';
import 'data/push_notification_listener.dart';
import 'home_page/home_page.dart';
import 'intro_page/intro_page.dart';
import 'review_page/reply_gmb.dart';
import 'unirson_check_in_page/unirosn_check_in_page.dart';

class Router {
  final BuildContext context;
  Function unauthenticatedHandler;

  Router({@required this.context}) {
   unauthenticatedHandler = (BuildContext context) =>
        Navigator.of(context).pushReplacementNamed(IntroPage.routeName);
  }

  routeGenerator(RouteSettings settings) {
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
  }
}
