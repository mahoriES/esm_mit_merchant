import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/home_page/app_drawer.dart';
import 'package:foore/logo_page/logo_page.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

typedef void AuthGuardUnauthenticatedHandler(BuildContext context);

class AuthGuard extends StatefulWidget {
  final Widget child;
  final Widget unauthenticatedPage;

  AuthGuard({
    @required this.child,
    @required this.unauthenticatedPage,
  }) {
    assert(this.child != null);
    assert(this.unauthenticatedPage != null);
  }

  @override
  _AuthGuardState createState() {
    return new _AuthGuardState();
  }
}

class _AuthGuardState extends State<AuthGuard> {
  Widget currentWidget;

  @override
  void initState() {
    super.initState();
    currentWidget = LogoPage();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    // _subscription =
    //     authBloc.authStateObservable.listen(_onAuthenticationChange);

    return StreamBuilder<AuthState>(
      stream: authBloc.authStateObservable,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isLoading) {
            currentWidget = LogoPage();
          } else if (snapshot.data.isLoggedIn) {
            currentWidget = widget.child;
          } else if (snapshot.data.isLoggedOut) {
            currentWidget = widget.unauthenticatedPage;
          }
        }
        return Scaffold(
          drawer: AppDrawer(),
          drawerEnableOpenDragGesture: false,
          appBar: AppBar(
            title: Text(
              AppTranslations.of(context).text("reviews_page_title"),
            ),
          ),
          body: currentWidget,
        );
      },
    );
  }
}
