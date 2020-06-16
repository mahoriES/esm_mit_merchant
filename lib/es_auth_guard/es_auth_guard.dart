import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/logo_page/logo_page.dart';
import 'package:provider/provider.dart';

typedef void EsAuthGuardUnauthenticatedHandler(BuildContext context);
typedef void EsAuthGuardNoMerchantProfileHandler(BuildContext context);

class EsAuthGuard extends StatefulWidget {
  final Widget child;
  final EsAuthGuardUnauthenticatedHandler unauthenticatedHandler;
  final EsAuthGuardNoMerchantProfileHandler noMerchantProfileHandler;

  EsAuthGuard({
    @required this.child,
    @required this.unauthenticatedHandler,
    @required this.noMerchantProfileHandler,
  }) {
    assert(this.child != null);
    assert(this.unauthenticatedHandler != null);
  }

  @override
  _EsAuthGuardState createState() {
    return new _EsAuthGuardState();
  }
}

class _EsAuthGuardState extends State<EsAuthGuard> {
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
          if (snapshot.data.isEsLoading) {
            currentWidget = LogoPage();
          } else if (snapshot.data.isEsMerchantLoggedIn) {
            currentWidget = widget.child;
          }
        }
        return currentWidget;
      },
    );
  }

  _onAuthenticationChange(AuthState authState) {
    if (authState.isEsLoggedOut) {
      widget.unauthenticatedHandler(context);
    } else if(authState.isMerchantProfileNotExist) {
      widget.noMerchantProfileHandler(context);
    }
  }
}
