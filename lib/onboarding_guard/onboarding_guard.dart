import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding.dart';
import 'package:foore/logo_page/logo_page.dart';
import 'package:provider/provider.dart';

typedef void OnboardingGuardOnboardingRequiredHandler(BuildContext context);

class OnboardingGuard extends StatefulWidget {
  final Widget child;
  final OnboardingGuardOnboardingRequiredHandler onboardingRequiredHandler;

  OnboardingGuard({
    @required this.child,
    @required this.onboardingRequiredHandler,
  }) {
    assert(this.child != null);
    assert(this.onboardingRequiredHandler != null);
  }

  @override
  _OnboardingGuardState createState() {
    return new _OnboardingGuardState();
  }
}

class _OnboardingGuardState extends State<OnboardingGuard> {
  Widget currentWidget;
  StreamSubscription<OnboardingState> _subscription;

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
    final onboardingBloc = Provider.of<OnboardingBloc>(context);
    onboardingBloc.getData();
    _subscription = onboardingBloc.onboardingStateObservable
        .listen(_onOnboardingChange);

    return StreamBuilder<OnboardingState>(
      stream: onboardingBloc.onboardingStateObservable,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isShowChild) {
            currentWidget = widget.child;
          }
        }
        return currentWidget;
      },
    );
  }

  _onOnboardingChange(OnboardingState onboardingState) {
    if (onboardingState.isOnboardingRequired) {
      widget.onboardingRequiredHandler(context);
    }
  }
}
