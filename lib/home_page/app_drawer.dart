import 'package:foore/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:foore/environments/environment.dart';

import 'package:foore/language_selection_page/language_selection_page.dart';

import 'package:provider/provider.dart';
import 'package:foore/data/bloc/auth.dart';
import '../app_translations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            child: DrawerHeader(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 28.0,
                    margin: EdgeInsets.only(bottom: 8.0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Image(
                          image: AssetImage(
                            'assets/es-logo-small.png',
                          ),
                        ),
                        SizedBox(width: 20),
                        Image(
                          image: AssetImage('assets/logo-black.png'),
                        ),
                      ],
                    ),
                  ),
                  new VersionName()
                ],
              ),

              decoration: BoxDecoration(
                color: Color.fromARGB(80, 233, 233, 233),
              ),
            ),
            height: 140,
          ),
          StreamBuilder(
            stream: authBloc.authStateObservable,
            builder: (context, AsyncSnapshot<AuthState> snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              return ListTile(
                title: Text(snapshot.data.getMerchantName()),
                subtitle: Text(snapshot.data.getMerchantPhone()),
              );
            },
          ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text(
                AppTranslations.of(context).text("drawer_button_language")),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LanguageSelectionPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title:
                Text(AppTranslations.of(context).text("drawer_button_logout")),
            onTap: () {
              authBloc.logout(esLogout: true);
            },
          ),
        ],
      ),
    );
  }
}

class VersionName extends StatefulWidget {
  const VersionName({
    Key key,
  }) : super(key: key);

  @override
  _VersionNameState createState() => _VersionNameState();
}

class _VersionNameState extends State<VersionName> {
  var _versionName = '0.0.0';

  @override
  Widget build(BuildContext context) {
    getVersionName();
    return Text(
      'Version: $_versionName',
      style: Theme.of(context).textTheme.caption,
    );
  }

  getVersionName() async {
    var versionName = await Environment.version;
    setState(() {
      this._versionName = versionName;
    });
  }
}
