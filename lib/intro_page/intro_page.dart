import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/login.dart';
import 'package:foore/language_selection_page/language_selection_page.dart';
import 'package:foore/login_page/login_page.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

class IntroPage extends StatefulWidget {
  static const routeName = '/intro';

  IntroPage({Key key}) : super(key: key);

  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with AfterLayoutMixin<IntroPage> {
  var isShowLogin = false;
  StreamSubscription<LoginState> _subscription;

  _showFailedAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login failed'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final loginBloc = Provider.of<LoginBloc>(context);
    _subscription =
        loginBloc.loginStateObservable.listen(this._onLoginStateChange);
  }

  _onLoginStateChange(
    LoginState state,
  ) {
    if (state.isSubmitFailed) {
      this._showFailedAlertDialog();
    }
  }

  Future<bool> _onWillPop() async {
    if (isShowLogin) {
      setState(() {
        isShowLogin = false;
      });
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onSelectLanguage() {
      setState(() {
        isShowLogin = true;
      });
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: isShowLogin
          ? introLogin(context)
          : LanguageSelectionPage(onSelectLanguage: onSelectLanguage),
    );
  }

  Widget introLogin(BuildContext context) {
    final loginBloc = Provider.of<LoginBloc>(context);
    return Scaffold(
      body: StreamBuilder<LoginState>(
          stream: loginBloc.loginStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return SafeArea(
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
                    Center(
                      child: Stack(
                        children: <Widget>[
                          Opacity(
                            opacity: snapshot.data.isLoading ? 0.5 : 1.0,
                            child: Container(
                              margin:
                                  EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
                              child: RaisedButton(
                                  padding: EdgeInsets.all(0.0),
                                  color: const Color(0xFF4285F4),
                                  onPressed: () {
                                    loginBloc.signInWithGoogle(context);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.all(1.0),
                                        padding: EdgeInsets.all(4.0),
                                        child: Image.asset(
                                          'assets/google-icon.png',
                                          height: 48.0,
                                        ),
                                      ),
                                      Container(
                                          color: const Color(0xFF4285F4),
                                          padding: EdgeInsets.only(
                                            left: 15.0,
                                            right: 15.0,
                                            top: 20.0,
                                            bottom: 20.0,
                                          ),
                                          child: new Text(
                                            AppTranslations.of(context).text(
                                                "intro_page_button_google"),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          )),
                                    ],
                                  )),
                            ),
                          ),
                          Positioned(
                            left: 130.0,
                            top: 8.0,
                            child: snapshot.data.isLoading
                                ? CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        if (!snapshot.data.isLoading) {
                          Navigator.of(context).pushNamed(LoginPage.routeName);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          AppTranslations.of(context)
                              .text("intro_page_button_login"),
                          style: Theme.of(context).textTheme.button.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          }),
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
              color: Theme.of(context).canvasColor,
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
