import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:foore/environments/environment.dart';
import 'package:foore/language_selection_page/language_selection_page.dart';
import 'package:foore/setting_page/settting_page.dart';
import 'package:foore/share_page/share_page.dart';
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
                    margin: EdgeInsets.only(bottom: 5.0),
                    alignment: Alignment.centerLeft,
                    child: Image(
                      image: AssetImage('assets/logo-black.png'),
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
          StreamBuilder<AuthState>(
              stream: authBloc.authStateObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Container(
                      height: double.infinity,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFECEFF1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        snapshot.data.firstLetterOfUserName,
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  title: Text(snapshot.data.userName ?? ''),
                  subtitle: Text(snapshot.data.userEmail ?? ''),
                );
              }),
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
            leading: Icon(Icons.share),
            title: Text(
                AppTranslations.of(context).text("share_page_button_share")),
            onTap: () {
              Navigator.of(context).popAndPushNamed(SharePage.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title:
                Text(AppTranslations.of(context).text("drawer_button_logout")),
            onTap: () {
              authBloc.logout();
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
