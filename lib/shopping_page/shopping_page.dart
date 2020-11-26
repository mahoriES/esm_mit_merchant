import 'package:flutter/material.dart';
import 'package:foore/es_login_page/es_login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_translations.dart';

class ShoppingPage extends StatefulWidget {
  static const routeName = '/shopping';

  ShoppingPage({Key key}) : super(key: key);

  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  Future<void> _launchPreRegisterUrl() async {
    final url = 'https://forms.gle/rqqNdqoY8LE4qDW68';
    if (await canLaunch(url)) {
      await launch(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text(
          //   'My Store',
          // ),
          ),
      // drawer: AppDrawer(),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                //Container(
                //  width: MediaQuery.of(context).size.width * 0.5,
                //  height: MediaQuery.of(context).size.width * 0.5,
                //  child: Image.asset('assets/es-logo-small.png'),
                //),
                Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image(
                        image: AssetImage(
                          'assets/es-logo-small.png',
                        ),
                      ),
                      SizedBox(width: 20),
                      Image(
                        image: AssetImage('assets/logo-black.png'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                //Text('Let customers order from home',
                //    style: Theme.of(context).textTheme.title),
                //SizedBox(
                //  height: 16,
                //),
                Container(
                  margin: EdgeInsets.only(top:8),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                       AppTranslations.of(context).text("login_page_create_your_online_store")
                       + '\n&\n' 
                       +  AppTranslations.of(context).text("login_page_get_more_google_reviews"),
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    )),
                Flexible(
                  flex: 3,
                  child: Container(),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 25,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(EsLoginPage.routeName);
                  },
                  child: Container(
                    child: Text(
                      AppTranslations.of(context).text("login_page_Login_with_phone"),
                      style: Theme.of(context).textTheme.subhead.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 25,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EsLoginPage.signUpRouteName);
                  },
                  child: Container(
                    child: Text(
                      AppTranslations.of(context).text("login_page_Create_new_account"),
                    ),
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
