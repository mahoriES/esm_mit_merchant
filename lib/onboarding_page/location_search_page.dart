import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/search_gmb/search_gmb.dart';
import 'package:provider/provider.dart';
import '../app_translations.dart';

class LocationSearchPage extends StatefulWidget {
  static const routeName = '/location-search';
  LocationSearchPage({Key key}) : super(key: key);

  @override
  _LocationSearchPageState createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage>
    with AfterLayoutMixin<LocationSearchPage> {
  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("onboarding_page_title"),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).errorColor.withOpacity(0.2),
                ),
                child: Text(
                  "You don't have any Google Business location for your Google account paragjnath@foore.in.",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Theme.of(context).errorColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  left: 16.0,
                  right: 16.0,
                ),
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Search for your Business and claim to manage that business.",
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: SearchMapPlaceWidget(
                  authBloc: authBloc,
                ),
              ),
              SizedBox(height: 100.0,),
              Text(
                "Can't find your business ?",
                style: Theme.of(context).textTheme.caption,
              ),
              FlatButton(
                child: Text(
                  'Create a business on Google',
                  style: Theme.of(context).textTheme.button.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                ),
                onPressed: () {},
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
