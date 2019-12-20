import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/account_setting.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/gmb_location.dart';
import 'package:foore/onboarding_page/location_claim.dart';
import 'package:foore/onboarding_page/location_search_page.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:foore/setting_page/sender_code.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';

class SettingPage extends StatefulWidget {
  static const routeName = '/settings';
  @override
  SettingPageState createState() => SettingPageState();

  static Route generateRoute(RouteSettings settings, HttpService httpService) {
    return MaterialPageRoute(
        builder: (context) => Provider(
              builder: (context) =>
                  AccountSettingBloc(httpService: httpService),
              dispose: (context, value) => value.dispose(),
              child: SettingPage(),
            ));
  }
}

class SettingPageState extends State<SettingPage>
    with AfterLayoutMixin<SettingPage> {
  onCreateStore(GmbLocation gmbLocation) {
    var accSettingBloc = Provider.of<AccountSettingBloc>(context);
    accSettingBloc.createStoreForGmbLocations(gmbLocation.gmbLocationId, () {});
  }

  openCreateStore(
      AccountSettingBloc accountSettingBloc, GmbLocation gmbLocation) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: StreamBuilder<AccountSettingState>(
              stream: accountSettingBloc.accountSettingStateObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                if (snapshot.data.isSubmitting ||
                    snapshot.data.isSubmitSuccess) {
                  return Container();
                }
                return Text('Are you sure?');
              }),
          content: StreamBuilder<AccountSettingState>(
              stream: accountSettingBloc.accountSettingStateObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                if (snapshot.data.isSubmitting) {
                  return Container(
                      width: 50,
                      height: 50,
                      child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.data.isSubmitSuccess) {
                  return Container(
                      width: 50,
                      height: 50,
                      child: Text('Location connected.'));
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(sprintf('Connect %s to Foore',
                          [gmbLocation.gmbLocationName ?? ''])),
                    ),
                  ],
                );
              }),
          actions: <Widget>[
            StreamBuilder<AccountSettingState>(
                stream: accountSettingBloc.accountSettingStateObservable,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  if (snapshot.data.isSubmitting) {
                    return Container();
                  }

                  if (snapshot.data.isSubmitSuccess) {
                    return FlatButton(
                      child: Text('Done'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    );
                  }
                  return FlatButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      onCreateStore(gmbLocation);
                    },
                  );
                })
          ],
        );
      },
    );
    accountSettingBloc.getData();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    var accSettingBloc = Provider.of<AccountSettingBloc>(context);
    accSettingBloc.getData();
    accSettingBloc.accountSettingStateObservable.listen((state) {
      state.gmbLocationWithUiData.forEach((ok) {
        print(ok.toJson());
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    addNewLocation() {
      Navigator.of(context).pushNamed(LocationSearchPage.routeName);
    }

    final onBoardingGuard = Provider.of<OnboardingGuardBloc>(context);
    final accSettingBloc = Provider.of<AccountSettingBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: StreamBuilder<AccountSettingState>(
          stream: accSettingBloc.accountSettingStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            if (snapshot.data.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data.isLoadingFailed) {
              return SomethingWentWrong(
                onRetry: accSettingBloc.getData,
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: 32.0,
                  top: 32.0,
                ),
                children: <Widget>[
                  Text('SMS sender code',
                      style: Theme.of(context).textTheme.subtitle),
                  Row(
                    children: <Widget>[
                      StreamBuilder<OnboardingGuardState>(
                          stream: onBoardingGuard.onboardingStateObservable,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            return Text(snapshot.data.smsCode,
                                style: Theme.of(context).textTheme.subhead);
                          }),
                      FlatButton(
                        child: Text('Change',
                            style: Theme.of(context).textTheme.caption.copyWith(
                                color: Theme.of(context).primaryColor)),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(SenderCodePage.routeName);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text('My Google Business Locations',
                      style: Theme.of(context).textTheme.subtitle),
                  locationListWidget(context),
                  SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    child: Center(
                      child: OutlineButton(
                        onPressed: addNewLocation,
                        child: Text('Add new Google Location'),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }

  Widget locationListWidget(BuildContext context) {
    var accSettingBloc = Provider.of<AccountSettingBloc>(context);
    onVerify(GmbLocation location) {
      final arguments = Map<String, dynamic>();
      arguments['locationItem'] = GmbLocationItem.fromGmbLocation(location);
      Navigator.pushNamed(context, LocationClaimPage.routeName,
          arguments: arguments);
    }

    return Container(
      child: StreamBuilder<AccountSettingState>(
        stream: accSettingBloc.accountSettingStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: snapshot.data.gmbLocationWithUiData
                .map((gmbLocationWithUiData) {
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        gmbLocationWithUiData.gmbLocation.gmbLocationName ?? '',
                        style: Theme.of(context).textTheme.subhead),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: gmbLocationWithUiData.accountReviewInfo != null
                            ? Row(
                                children: <Widget>[
                                  Text(gmbLocationWithUiData
                                      .accountReviewInfo.rating
                                      .toStringAsFixed(1)),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  StarDisplay(
                                    value: gmbLocationWithUiData
                                        .accountReviewInfo.rating
                                        .toInt(),
                                  ),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  Text('(' +
                                      gmbLocationWithUiData
                                          .accountReviewInfo.numReview
                                          .toString() +
                                      ')')
                                ],
                              )
                            : null,
                      ),
                    ),
                    Container(
                      child: gmbLocationWithUiData.getLocationAddress() == ''
                          ? null
                          : Text(gmbLocationWithUiData.getLocationAddress(),
                              style: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(color: Colors.black54)),
                    ),
                    Container(
                      child: gmbLocationWithUiData.foLocation == null &&
                              gmbLocationWithUiData.getIsLocationVerified()
                          ? RaisedButton(
                              child: Text('Connect'),
                              onPressed: () {
                                openCreateStore(accSettingBloc,
                                    gmbLocationWithUiData.gmbLocation);
                              },
                            )
                          : null,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 4.0,
                      ),
                      child: gmbLocationWithUiData.foLocation != null
                          ? Text('connected',
                              style: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(color: Colors.green))
                          : null,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 4.0,
                      ),
                      child: !gmbLocationWithUiData.getIsLocationVerified()
                          ? Text(
                              'This location needs verification before you can use',
                              style: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(color: Colors.yellow[900]))
                          : null,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        top: 4.0,
                      ),
                      child: !gmbLocationWithUiData.getIsLocationVerified()
                          ? RaisedButton(
                              child: Text(
                                'Verify',
                              ),
                              onPressed: () {
                                onVerify(gmbLocationWithUiData.gmbLocation);
                              },
                            )
                          : null,
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class StarDisplay extends StatelessWidget {
  final int value;
  const StarDisplay({Key key, this.value = 0})
      : assert(value != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
          size: 18.0,
          color: Color.fromARGB(255, 239, 206, 74),
        );
      }),
    );
  }
}
