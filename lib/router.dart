import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foore/create_promotion_page/create_promotion_page.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/google_login_not_done_page/google_login_not_done_page.dart';
import 'package:foore/onboarding_page/location_claim.dart';
import 'package:foore/setting_page/sender_code.dart';
import 'package:foore/setting_page/settting_page.dart';
import 'package:foore/share_page/share_page.dart';
import 'package:provider/provider.dart';

import 'auth_guard/auth_guard.dart';
import 'data/bloc/onboarding.dart';
import 'data/bloc/people.dart';
import 'data/http_service.dart';
import 'data/model/feedback.dart';
import 'data/model/unirson.dart';
import 'home_page/home_page.dart';
import 'intro_page/intro_page.dart';
import 'login_page/login_page.dart';
import 'onboarding_guard/onboarding_guard.dart';
import 'onboarding_page/location_search_page.dart';
import 'onboarding_page/location_verify.dart';
import 'onboarding_page/onboarding_page.dart';
import 'review_page/reply_gmb.dart';
import 'unirson_check_in_page/unirson_check_in_page.dart';

class Router {
  static const homeRoute = '/';
  static const testRoute = CreatePromotionPage.routeName;
  final unauthenticatedHandler = (BuildContext context) => Navigator.of(context)
      .pushNamedAndRemoveUntil(
          IntroPage.routeName, (Route<dynamic> route) => false);
  final onboardingRequiredHandler = (BuildContext context) =>
      Navigator.of(context).pushNamedAndRemoveUntil(
          OnboardingPage.routeName, (Route<dynamic> route) => false);

  final HttpService httpServiceBloc;
  final AuthBloc authBloc;

  Router({@required this.httpServiceBloc, @required this.authBloc});

  Route<dynamic> routeGenerator(RouteSettings settings) {
    this.authBloc.foAnalytics.setCurrentScreen(settings.name);
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(
          builder: (context) => AuthGuard(
            unauthenticatedHandler: unauthenticatedHandler,
            child: OnboardingGuard(
              onboardingRequiredHandler: onboardingRequiredHandler,
              child: MultiProvider(
                providers: [
                  Provider<PeopleBloc>(
                    builder: (context) => PeopleBloc(httpServiceBloc),
                    dispose: (context, value) => value.dispose(),
                  ),
                ],
                child: HomePage(),
              ),
            ),
          ),
        );
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
      case OnboardingPage.routeName:
        return MaterialPageRoute(
          builder: (context) => AuthGuard(
              unauthenticatedHandler: unauthenticatedHandler,
              child: Provider<OnboardingBloc>(
                builder: (context) => OnboardingBloc(httpServiceBloc),
                dispose: (context, value) => value.dispose(),
                child: OnboardingPage(),
              )),
        );
        break;
      case LoginPage.routeName:
        return MaterialPageRoute(
          builder: (context) => LoginPage(),
        );
        break;
      case LocationSearchPage.routeName:
        return MaterialPageRoute(
          builder: (context) => LocationSearchPage(),
        );
        break;
      case LocationClaimPage.routeName:
        return LocationClaimPage.generateRoute(
          settings,
          authBloc: this.authBloc,
          httpService: this.httpServiceBloc,
        );
        break;
      case LocationVerifyPage.routeName:
        return LocationVerifyPage.generateRoute(
          settings,
          authBloc: this.authBloc,
          httpService: this.httpServiceBloc,
        );
        break;
      case GoogleLoginNotDonePage.routeName:
        return GoogleLoginNotDonePage.generateRoute(settings);
        break;
      case SharePage.routeName:
        return SharePage.generateRoute(settings);
        break;
      case SettingPage.routeName:
        return SettingPage.generateRoute(settings);
        break;
      case SenderCodePage.routeName:
        return SenderCodePage.generateRoute(settings, httpServiceBloc);
        break;
      case CreatePromotionPage.routeName:
        return CreatePromotionPage.generateRoute(
            settings, this.httpServiceBloc);
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
