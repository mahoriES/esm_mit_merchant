import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:foore/login_page/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_translations.dart';

class IntroPage extends StatefulWidget {
  IntroPage({Key key}) : super(key: key);

  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool _isShowLogin = false;
  @override
  Widget build(BuildContext context) {
    return _isShowLogin
        ? LoginPage()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        CarouselWithIndicator(),
                        Positioned(
                          right: 30.0,
                          top: 30.0,
                          child: Container(
                            width: 70.0,
                            child: Image(
                              image: AssetImage('assets/logo-black.png'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0)),
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        elevation: 0,
                        color: Colors.blue,
                        onPressed: () async {
                          const url = 'https://app.foore.in/signup/';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            AppTranslations.of(context)
                                .text("login_page_button_create_account"),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black45),
                            borderRadius: new BorderRadius.circular(5.0)),
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        elevation: 0,
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _isShowLogin = true;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            AppTranslations.of(context)
                                .text("otp_page_button_login"),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
  }
}

class CarouselWithIndicator extends StatefulWidget {
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;

  final slides = [
    Container(
      // color: Color.fromRGBO(249, 249, 249, 1),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 30.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 150,
            padding: EdgeInsets.only(bottom: 30),
            child: Image(
              image: AssetImage('assets/button-click.png'),
            ),
          ),
          Text(
            "Check-in to collect Google reviews.",
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(
            height: 30.0,
          ),
          Text(
            "गूगल रिव्यू एकत्र करने के लिए चेक-इन करें।",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    ),
    Container(
      // color: Color.fromRGBO(249, 249, 249, 1),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 30.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 150,
            padding: EdgeInsets.only(bottom: 30),
            child: Image(
              image: AssetImage('assets/growth.png'),
            ),
          ),
          Text(
            "More Google reviews, more customers.",
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(
            height: 30.0,
          ),
          Text(
            "अधिक गूगल रिव्यू, अधिक ग्राहक।",
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          top: 0.0,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50.0),
              bottomRight: Radius.circular(50.0),
            ),
            child: Container(
              color: Color.fromRGBO(249, 249, 249, 1),
            ),
          )),
      CarouselSlider(
        items: slides,
        autoPlay: true,
        viewportFraction: 1.0,
        autoPlayInterval: const Duration(seconds: 6),
        height: 350.0,
        onPageChanged: (index) {
          setState(() {
            _current = index;
          });
        },
      ),
      Positioned(
          bottom: 10.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: mapIndexed(slides, (index, value) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4)),
              );
            }).toList(),
          )),
    ]);
  }
}

Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;

  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}
