import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

class GoogleLoginNotDonePage extends StatelessWidget {
  const GoogleLoginNotDonePage({Key key}) : super(key: key);

  static const routeName = '/google-login-not-done';

  static Route generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => GoogleLoginNotDonePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    'You need to login with Google to create or manage Google locations',
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                SizedBox(
                  height: 32.0,
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
              ]),
        )));
  }
}
