import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/home_page/app_drawer.dart';

import '../app_translations.dart';

class SenderCodePage extends StatefulWidget {
  static const routeName = '/sender-code';
  @override
  SenderCodePageState createState() => SenderCodePageState();

  static Route generateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => SenderCodePage());
  }
}

class SenderCodePageState extends State<SenderCodePage>
    with AfterLayoutMixin<SenderCodePage> {
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
        title: Text(
          'Sender Code',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
        elevation: 0,
        brightness: Brightness.dark,
        iconTheme: IconThemeData.fallback().copyWith(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                color: Colors.blue,
                height: 250.0,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 50.0,
                ),
                child: Container(
                  height: 200.0,
                  child: Center(
                    child: Image(
                      image: AssetImage('assets/sms-code.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Text('Change Sender Code'),
          ),
          Padding(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'oFOORE',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FoSubmitButton(
          text: AppTranslations.of(context).text("checkin_page_button_submit"),
          onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
