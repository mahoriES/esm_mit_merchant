import 'package:flutter/material.dart';
import 'package:foore/create_promotion_page/create_promotion_page.dart';
import 'package:foore/data/bloc/analytics.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/es_home_page/es_home_page.dart';
import 'package:foore/people_page/people_page.dart';
import 'package:foore/review_page/review_page.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';
import 'app_drawer.dart';

class HomePage extends StatefulWidget {
  final String title;

  HomePage({this.title});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    PeoplePage(),
    Container(),
    ReviewPage(),
    Container()
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      final httpService = Provider.of<HttpService>(context);
      httpService.foAnalytics
          .trackUserEvent(name: FoAnalyticsEvents.nearby_promo_clicked);
      Navigator.of(context).pushNamed(CreatePromotionPage.routeName);
    } else if (index == 3) {
      Navigator.of(context).pushNamed(EsHomePage.routeName);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text(
              AppTranslations.of(context).text("tab_people"),
            ),
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12.0,
              backgroundColor: _selectedIndex != 1
                  ? Colors.grey[600]
                  : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: Icon(
                Icons.add,
                size: 14.0,
              ),
            ),
            title: Text(
              AppTranslations.of(context).text('tab_nearby'),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            title: Text(
              AppTranslations.of(context).text("tab_reviews"),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            title: Text(
              'My Store',
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
