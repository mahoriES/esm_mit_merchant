import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/logo_page/logo_page.dart';
import 'package:provider/provider.dart';

typedef void OnboardingGuardOnboardingRequiredHandler(BuildContext context);

class OnboardingGuard extends StatefulWidget {
  final Widget child;
  final Widget onboardingRequiredPage;

  OnboardingGuard({
    @required this.child,
    @required this.onboardingRequiredPage,
  }) {
    assert(this.child != null);
    assert(this.onboardingRequiredPage != null);
  }

  @override
  _OnboardingGuardState createState() {
    return new _OnboardingGuardState();
  }
}

class _OnboardingGuardState extends State<OnboardingGuard>  with AfterLayoutMixin<OnboardingGuard> {
  
  Widget currentWidget;
  StreamSubscription<OnboardingGuardState> _subscription;

  @override
  void afterFirstLayout(BuildContext context) {
     final onboardingBloc = Provider.of<OnboardingGuardBloc>(context);
     onboardingBloc.getData();
  }


  @override
  void initState() {
    super.initState();
    currentWidget = LogoPage();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   if (_subscription != null) {
  //     _subscription.cancel();
  //     _subscription = null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final onboardingBloc = Provider.of<OnboardingGuardBloc>(context);
    // _subscription = onboardingBloc.onboardingStateObservable
    //     .listen(_onOnboardingChange);

    return StreamBuilder<OnboardingGuardState>(
      stream: onboardingBloc.onboardingStateObservable,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isShowChild) {
            currentWidget = widget.child;
          } else if(snapshot.data.isOnboardingRequired) {
            currentWidget = widget.onboardingRequiredPage;
          }
        }
        return currentWidget;
      },
    );
  }

  // _onOnboardingChange(OnboardingGuardState onboardingState) {
  //   if (onboardingState.isOnboardingRequired) {
  //     widget.onboardingRequiredHandler(context);
  //   }
  // }
}
