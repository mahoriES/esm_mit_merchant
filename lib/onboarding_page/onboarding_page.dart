import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/bloc/onboarding.dart';
import 'package:foore/data/model/gmb_location.dart';
import 'package:foore/onboarding_page/location_claim.dart';
import 'package:foore/onboarding_page/location_search_page.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:provider/provider.dart';
import '../app_translations.dart';
import 'package:youtube_player/youtube_player.dart';

class OnboardingPage extends StatefulWidget {
  static const routeName = '/onboarding';
  OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with AfterLayoutMixin<OnboardingPage> {
  StreamSubscription<OnboardingState> _subscription;
  @override
  void afterFirstLayout(BuildContext context) {
    final onboardingBloc = Provider.of<OnboardingBloc>(context);
    _subscription =
        onboardingBloc.onboardingStateObservable.listen(_onOnboardingChange);
    onboardingBloc.getData();
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  _onOnboardingChange(OnboardingState state) {
    if (state.isShowNoGmbLocations) {
      Navigator.pushNamed(context, LocationSearchPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingBloc = Provider.of<OnboardingBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("onboarding_page_title"),
        ),
      ),
      body: StreamBuilder<OnboardingState>(
          stream: onboardingBloc.onboardingStateObservable,
          builder: (context, snapshot) {
            Widget child = Container();
            if (snapshot.hasData) {
              if (snapshot.data.isShowLocationList) {
                child = SelectLocations(locations: snapshot.data.locations);
              } else if (snapshot.data.isLoading) {
                child = Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.data.isLoadingFailed) {
                child = Text('Loading Failed');
              } else if (snapshot.data.isShowNoGmbLocations ||
                  snapshot.data.isShowInsufficientPermissions) {
                child = noGmbLocations(context);
              }
            }
            return child;
          }),
    );
  }

  Widget noGmbLocations(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return SafeArea(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              Text(
                AppTranslations.of(context)
                    .text("onboarding_page_no_location_message"),
                style: Theme.of(context).textTheme.headline,
              ),
              Expanded(
                child: Container(),
              ),
              YoutubePlayer(
                context: context,
                source: "T2mqrx20_Sg",
                quality: YoutubeQuality.HD,
                autoPlay: false,
              ),
              Expanded(
                child: Container(),
              ),
              RaisedButton(
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                ),
                onPressed: () {
                  authBloc.logout();
                },
                child: Container(
                  width: double.infinity,
                  child: Text(
                    AppTranslations.of(context).text("drawer_button_logout"),
                    style: Theme.of(context).textTheme.button.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
            ]),
      ),
    );
  }
}

class SelectLocations extends StatelessWidget {
  final List<GmbLocation> locations;

  const SelectLocations({Key key, this.locations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final onboardingBloc = Provider.of<OnboardingBloc>(context);
    return StreamBuilder<OnboardingState>(
        stream: onboardingBloc.onboardingStateObservable,
        builder: (context, snapshot) {
          Widget child = Container();
          if (snapshot.hasData) {
            child = locationList(context, onboardingBloc, snapshot);
          }
          return child;
        });
  }

  Widget locationList(BuildContext context, OnboardingBloc onboardingBloc,
      AsyncSnapshot<OnboardingState> snapshot) {
    onVerify(GmbLocation location) {
      final arguments = Map<String, dynamic>();
      arguments['locationItem'] = GmbLocationItem.fromGmbLocation(location);
      Navigator.pushNamed(context, LocationClaimPage.routeName, arguments:  arguments);
    }

    return SafeArea(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                AppTranslations.of(context)
                    .text("onboarding_page_select_locations"),
                style: Theme.of(context).textTheme.subtitle,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: locations.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  if (onboardingBloc.getIsLocationVerified(locations[index])) {
                    return CheckboxListTile(
                      title: Text(locations[index].gmbLocationName),
                      subtitle: Text(
                          onboardingBloc.getLocationAddress(locations[index])),
                      value: locations[index].isSelectedUi == true,
                      onChanged: (bool value) {
                        onboardingBloc.setLocationSelected(
                            locations[index], value);
                      },
                    );
                  } else {
                    return ListTile(
                      title: Text(locations[index].gmbLocationName),
                      subtitle: Text(
                          onboardingBloc.getLocationAddress(locations[index])),
                      trailing: FlatButton(
                        onPressed: () => onVerify(locations[index]),
                        child: Text('Verify'),
                      ),
                    );
                  }
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              width: double.infinity,
              child: RaisedButton(
                padding: EdgeInsets.symmetric(
                  vertical: 20.0,
                ),
                child: snapshot.data.isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      )
                    : Text(AppTranslations.of(context)
                        .text("onboarding_page_continue")),
                onPressed: () {
                  onboardingBloc.createStoreForGmbLocations(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
