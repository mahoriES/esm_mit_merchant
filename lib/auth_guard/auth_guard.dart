import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/logo_page/logo_page.dart';
import 'package:provider/provider.dart';

typedef void AuthGuardUnauthenticatedHandler(BuildContext context);

class AuthGuard extends StatefulWidget {
  final Widget child;
  final AuthGuardUnauthenticatedHandler unauthenticatedHandler;

  AuthGuard({
    @required this.child,
    @required this.unauthenticatedHandler,
  }) {
    assert(this.child != null);
    assert(this.unauthenticatedHandler != null);
  }

  @override
  _AuthGuardState createState() {
    return new _AuthGuardState();
  }
}

class _AuthGuardState extends State<AuthGuard> {
  Widget currentWidget;
  StreamSubscription<AuthState> _subscription;

  @override
  void initState() {
    super.initState();
    currentWidget = LogoPage();
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    _subscription =
        authBloc.authStateObservable.listen(_onAuthenticationChange);

    return StreamBuilder<AuthState>(
      stream: authBloc.authStateObservable,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isLoading) {
            currentWidget = LogoPage();
          } else if (snapshot.data.isLoggedIn) {
            currentWidget = widget.child;
          }
        }
        return currentWidget;
      },
    );
  }

  _onAuthenticationChange(AuthState authState) {
    if (authState.isLoggedOut) {
      widget.unauthenticatedHandler(context);
    }
  }
}
