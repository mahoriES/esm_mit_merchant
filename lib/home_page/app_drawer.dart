import 'package:flutter/material.dart';
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
                    margin: EdgeInsets.only(bottom: 5.0),
                    alignment: Alignment.centerLeft,
                    child: Image(
                      image: AssetImage('assets/logo-black.png'),
                    ),
                  ),
                  Text(
                    'Version: 0.0.6',
                    style: Theme.of(context).textTheme.caption,
                  )
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
