import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/app_update_bloc.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/logo_page/logo_page.dart';
import 'package:provider/provider.dart';

typedef void EsAuthGuardUnauthenticatedHandler(BuildContext context);
typedef void EsAuthGuardNoMerchantProfileHandler(BuildContext context);

class EsAuthGuard extends StatefulWidget {
  final Widget child;
  final Widget unauthenticatedPage;
  final Widget noMerchantProfilePage;

  EsAuthGuard({
    @required this.child,
    @required this.unauthenticatedPage,
    @required this.noMerchantProfilePage,
  }) {
    assert(this.child != null);
    assert(this.unauthenticatedPage != null);
    assert(this.noMerchantProfilePage != null);
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<EsAppUpdateBloc>(context, listen: false)
          .checkForUpdate(context);
    });
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
    return StreamBuilder<AuthState>(
      stream: authBloc.authStateObservable,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEsLoading) {
            currentWidget = SizedBox.shrink();
          } else if (snapshot.data.isEsMerchantLoggedIn) {
            currentWidget = widget.child;
          } else if (snapshot.data.isEsLoggedOut) {
            currentWidget = widget.unauthenticatedPage;
          } else if (snapshot.data.isMerchantProfileNotExist) {
            currentWidget = widget.noMerchantProfilePage;
          }
        }
        return currentWidget;
      },
    );
  }
}
