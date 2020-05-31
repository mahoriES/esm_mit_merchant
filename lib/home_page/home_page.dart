import 'package:flutter/material.dart';
import 'package:foore/create_promotion_page/create_promotion_page.dart';
import 'package:foore/data/bloc/analytics.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/people_page/people_page.dart';
import 'package:foore/review_page/review_page.dart';
import 'package:foore/shopping_page/shopping_page.dart';
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
    } else if(index==3) {
      Navigator.of(context).pushNamed(ShoppingPage.routeName);
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
            icon: Transform.translate(
              offset: Offset(0, -10),
              child: Transform.scale(
                scale: 1.3,
                child: CircleAvatar(
                  child: Icon(Icons.add),
                  backgroundColor: _selectedIndex != 1
                      ? Colors.grey[600]
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
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
            icon: Icon(Icons.shopping_cart),
            title: Text(
              'Go online',
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
