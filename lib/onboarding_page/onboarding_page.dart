import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding.dart';
import 'package:foore/data/model/gmb_location.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';
import '../router.dart';

class OnboardingPage extends StatefulWidget {
  static const routeName = '/onboarding';
  OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with AfterLayoutMixin<OnboardingPage> {
  @override
  void afterFirstLayout(BuildContext context) {
    final onboardingBloc = Provider.of<OnboardingBloc>(context);
    onboardingBloc.getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Provider.of<OnboardingBloc>(context).dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingBloc = Provider.of<OnboardingBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Locations",
        ),
      ),
      body: StreamBuilder<OnboardingState>(
          stream: onboardingBloc.onboardingStateObservable,
          builder: (context, snapshot) {
            Widget child = Container();
            if (snapshot.hasData) {
              if (snapshot.data.isShowLocationList) {
                child = SelectLocations(locations: snapshot.data.locations);
              }
            }
            return child;
          }),
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
            child = SafeArea(
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
                        'Select your Google Business Locations.,',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return CheckboxListTile(
                            title: Text(locations[index].gmbLocationName),
                            value: locations[index].isSelectedUi == true,
                            onChanged: (bool value) {
                              onboardingBloc.setLocationSelected(
                                  locations[index], value);
                            },
                          );
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
                                .text("checkin_page_button_submit")),
                        onPressed: () {
                          onboardingBloc.createStoreForGmbLocations(() {
                            Navigator.of(context).pushReplacementNamed(Router.homeRoute);
                            print('home route is pushed');
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return child;
        });
  }
}
