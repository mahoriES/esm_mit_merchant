import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/gmb_location.dart';
import 'package:foore/data/bloc/onboarding.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  static const routeName = '/onboarding';
  OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with AfterLayoutMixin<OnboardingPage> {
  @override
  void afterFirstLayout(BuildContext context) {
    final onboardingBloc = Provider.of<OnboardingBloc>(context);
    onboardingBloc.getData();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingBloc = Provider.of<OnboardingBloc>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                    value: true,
                    onChanged: (bool value) {},
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
                child: Text(
                  'Continue',
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
