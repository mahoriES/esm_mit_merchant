import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/account_setting.dart';
import 'package:foore/data/http_service.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: Padding(
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
                Text('oFoore', style: Theme.of(context).textTheme.subhead),
                FlatButton(
                  child: Text('Change',
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Theme.of(context).primaryColor)),
                  onPressed: () {},
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
                  onPressed: () {},
                  child: Text('Add new Google Location'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget locationListWidget(BuildContext context) {
    var accSettingBloc = Provider.of<AccountSettingBloc>(context);
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
                    Text(gmbLocationWithUiData.gmbLocation.gmbLocationName,
                        style: Theme.of(context).textTheme.subhead),
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
                              onPressed: () {},
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
                              onPressed: () {},
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
