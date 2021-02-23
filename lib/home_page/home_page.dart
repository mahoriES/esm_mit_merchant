import 'package:flutter/material.dart';
import 'package:foore/review_page/review_page.dart';
import 'package:foore/services/sizeconfig.dart';
import '../app_translations.dart';
import 'app_drawer.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/foore-home';

  final String title;

  HomePage({this.title});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      drawer: AppDrawer(),
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("reviews_page_title"),
        ),
      ),
      body: Center(
        child: ReviewPage(),
      ),
    );
  }
}
