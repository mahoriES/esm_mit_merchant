import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/auth.dart';

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
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Image(
                  image: AssetImage('assets/logo-black.png'),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(80, 233, 233, 233),
              ),
            ),
            height: 140,
          ),
          // ListTile(
          //   leading: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 6),
          //     child: Container(
          //         height: double.infinity,
          //         width: 50,
          //         alignment: Alignment.center,
          //         decoration: BoxDecoration(
          //           color: Color(0xFFECEFF1),
          //           shape: BoxShape.circle,
          //         ),
          //         child: Text(
          //           'P',
          //           style: TextStyle(
          //             color: Colors.orangeAccent,
          //             fontWeight: FontWeight.w400,
          //             fontSize: 16,
          //           ),
          //         )),
          //   ),
          //   title: Text('paragjnath'),
          //   subtitle: Text('paragjnath@foore.in'),
          //   onTap: () {
          //     // Update the state of the app.
          //     // ...
          //   },
          // ),
          Expanded(
            child: Container(),
            flex: 1,
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('Log out'),
            onTap: () {
              authBloc.logout();
            },
          ),
        ],
      ),
    );
  }
}
