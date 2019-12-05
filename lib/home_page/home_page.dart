import 'package:flutter/material.dart';
import 'package:foore/create_promotion_page/create_promotion_page.dart';
import 'package:foore/people_page/people_page.dart';
import 'package:foore/review_page/review_page.dart';

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
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed(CreatePromotionPage.routeName);
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
              'Nearby',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            title: Text(
              AppTranslations.of(context).text("tab_reviews"),
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
