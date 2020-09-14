import 'package:flutter/material.dart';
import 'package:foore/es_home_page/es_home_page.dart';
import 'package:foore/people_page/people_page.dart';
import 'package:foore/review_page/review_page.dart';

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
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    PeoplePage(),
    //Container(),
    ReviewPage(),
    Container()
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
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
