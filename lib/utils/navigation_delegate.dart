import 'package:flutter/material.dart';

class NavigationHandler {
  NavigationHandler._();
  static NavigationHandler _instance = NavigationHandler._();
  factory NavigationHandler() => _instance;

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}
