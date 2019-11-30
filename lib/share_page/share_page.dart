import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:provider/provider.dart';
import 'package:flare_flutter/flare_actor.dart';

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
      final ByteData bytes = await rootBundle.load('assets/google-icon.png');
      await Share.file(
          'Foore', 'google-icon.png', bytes.buffer.asUint8List(), 'image/png',
          text: 'Download Foore app. Go to $url');
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FoSubmitButton(
          text: "Share",
          onPressed: share,
          isLoading: isLoading,
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
                    'Win iphone x',
                    style: Theme.of(context).textTheme.title.copyWith(
                          color: Colors.white,
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
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
