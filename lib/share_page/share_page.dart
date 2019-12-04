import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:provider/provider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class SharePage extends StatefulWidget {
  SharePage({Key key}) : super(key: key);

  static const routeName = 'share';

  @override
  _SharePageState createState() => _SharePageState();

  static Route generateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => SharePage());
  }
}

class _SharePageState extends State<SharePage> {
  bool isLoading = false;

  share() async {
    final authBloc = Provider.of<AuthBloc>(context);
    setState(() {
      isLoading = true;
    });
    String url = await authBloc.getReferralUrl();
    await this._shareImage(url);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _shareImage(String url) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var languageCode = prefs.getString('language_code') ?? null;

      if (languageCode == 'hi') {
        final ByteData bytes = await rootBundle.load('assets/hindi-share.png');
        await Share.file(
            'Foore', 'hindi-share.png', bytes.buffer.asUint8List(), 'image/png',
            text: sprintf(
                AppTranslations.of(context).text('whatsapp_share_message'),
                [url]));
      } else {
        final ByteData bytes =
            await rootBundle.load('assets/english-share.png');
        await Share.file('Foore', 'english-share.png',
            bytes.buffer.asUint8List(), 'image/png',
            text: sprintf(
                AppTranslations.of(context).text('whatsapp_share_message'),
                [url]));
      }
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFA7E5D),
          automaticallyImplyLeading: true,
          elevation: 0,
          brightness: Brightness.dark,
          iconTheme: IconThemeData.fallback().copyWith(color: Colors.white),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
            bottom: 32.0,
          ),
          child: FoShareButton(
            onPressed: this.share,
            text: AppTranslations.of(context).text('share_page_button_share'),
            isLoading: isLoading,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [Color(0xFFFA7E5D), Color(0xFFF75362)]),
          ),
          child: SafeArea(
            child: Container(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    AppTranslations.of(context).text('share_page_title'),
                    style: Theme.of(context).textTheme.title.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Container(
                    height: 300,
                    width: 300,
                    child: Stack(
                      children: <Widget>[
                        FlareActor("assets/iphone.flr",
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            animation: "rotate"),
                        Positioned(
                          top: 70,
                          left: 100,
                          width: 100,
                          child: Image(
                            image: AssetImage('assets/iphone.png'),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    AppTranslations.of(context).text('share_page_main_text'),
                    style: Theme.of(context).textTheme.title.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    AppTranslations.of(context)
                        .text('share_page_description_text'),
                    style: Theme.of(context).textTheme.body1.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class FoShareButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final Function onPressed;
  const FoShareButton({this.text, this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 60,
        ),
        onPressed: null,
        child: Container(
            height: 22,
            width: 22,
            child: Center(child: CircularProgressIndicator())),
      );
    }
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 45,
      ),
      color: Colors.white,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(1.0),
            height: 16,
            width: 16,
            child: Image(
              image: AssetImage('assets/whatsapp.png'),
            ),
          ),
          Container(
              padding: EdgeInsets.only(
                left: 15.0,
              ),
              child: new Text(
                text,
                style: TextStyle(
                  color: Colors.green,
                ),
              )),
        ],
      ),
    );
  }
}
