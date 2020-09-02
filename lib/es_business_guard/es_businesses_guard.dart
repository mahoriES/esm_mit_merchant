import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/logo_page/logo_page.dart';
import 'package:provider/provider.dart';

typedef void EsBusinessesGuardRequiredHandler(BuildContext context);

class EsBusinessesGuard extends StatefulWidget {
  final Widget child;
  final EsBusinessesGuardRequiredHandler createBusinessRequiredHandler;

  EsBusinessesGuard({
    @required this.child,
    @required this.createBusinessRequiredHandler,
  }) {
    assert(this.child != null);
    assert(this.createBusinessRequiredHandler != null);
  }

  @override
  _EsBusinessesGuardState createState() {
    return new _EsBusinessesGuardState();
  }
}

class _EsBusinessesGuardState extends State<EsBusinessesGuard>
    with AfterLayoutMixin<EsBusinessesGuard> {
  Widget currentWidget;
  StreamSubscription<EsBusinessesState> _subscription;

  @override
  void afterFirstLayout(BuildContext context) {
    final esBusinessesBloc = Provider.of<EsBusinessesBloc>(context);
    esBusinessesBloc.getData();
  }

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
    final esBusinessesBloc = Provider.of<EsBusinessesBloc>(context);
    _subscription = esBusinessesBloc.esBusinessesStateObservable
        .listen(_onOnboardingChange);

    return StreamBuilder<EsBusinessesState>(
      stream: esBusinessesBloc.esBusinessesStateObservable,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isLoading) {
            currentWidget = LogoPage();
          } else if (snapshot.data.isShowBusinesses) {
            currentWidget = widget.child;
          }
        }
        return currentWidget;
      },
    );
  }

  _onOnboardingChange(EsBusinessesState esBusinessesState) {
    if (esBusinessesState.isCreateBusinessRequired) {
      widget.createBusinessRequiredHandler(context);
    }
  }
}
