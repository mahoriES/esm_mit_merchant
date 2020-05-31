import 'package:flutter/material.dart';
import 'package:foore/home_page/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'My Store',
        ),
      ),
      drawer: AppDrawer(),
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Icon(
                    Icons.shopping_cart,
                    size: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.grey[200],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text('Let customers order from home',
                    style: Theme.of(context).textTheme.title),
                SizedBox(
                  height: 16,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      'Create your online store',
                      textAlign: TextAlign.center,
                    )),
                Flexible(
                  flex: 3,
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, -15),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 25,
          ),
          onPressed: _launchPreRegisterUrl,
          child: Container(
            child: Text(
              'Pre-register',
              style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
