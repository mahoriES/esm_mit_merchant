import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/home_page/app_drawer.dart';
import 'package:foore/setting_page/sender_code.dart';

import '../app_translations.dart';

class SettingPage extends StatefulWidget {
  static const routeName = '/settings';
  @override
  SettingPageState createState() => SettingPageState();

  static Route generateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => SettingPage());
  }
}

class SettingPageState extends State<SettingPage>
    with AfterLayoutMixin<SettingPage> {
  @override
  void afterFirstLayout(BuildContext context) {}

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
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Sender Code'),
              subtitle: Text('Foore'),
              onTap: () {
                Navigator.of(context).popAndPushNamed(SenderCodePage.routeName);
              },
            )
          ],
        ),
      ),
    );
  }
}
