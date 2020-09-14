import 'package:flutter/material.dart';
import 'package:foore/es_business_profile/es_business_profile.dart';
import 'package:foore/es_order_page/es_order_page.dart';
import 'package:foore/home_page/home_page.dart';
import 'package:foore/menu_page/menu_page.dart';
import '../router.dart';

class EsHomePage extends StatefulWidget {
  static const routeName = '/';
  EsHomePage();
  @override
  _EsHomePageState createState() => _EsHomePageState();
}

class _EsHomePageState extends State<EsHomePage> {
  int _selectedIndex = 1;
  final List<Widget> _widgetOptions = <Widget>[
    EsOrderPage(),
    MenuPage(),
    EsBusinessProfile(),
    Container(),
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.of(context).pushNamed(HomePage.routeName);
    }
    {
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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            title: Text(
              'Orders',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            title: Text(
              'Products',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            title: Text(
              'Profile',
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            title: Text(
              "Reviews",
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
