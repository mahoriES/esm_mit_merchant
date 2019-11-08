import 'package:flutter/material.dart';
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
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    PeoplePage(),
    ReviewPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
