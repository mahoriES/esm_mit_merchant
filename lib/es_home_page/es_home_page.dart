import 'package:flutter/material.dart';
import 'package:foore/es_business_profile/es_business_profile.dart';
import 'package:foore/es_order_page/es_order_page.dart';
import 'package:foore/es_video_page/es_video_page.dart';
import 'package:foore/menu_page/menu_page.dart';
import '../router.dart';

class EsHomePage extends StatefulWidget {
  static const routeName = '/esHome';
  EsHomePage();
  @override
  _EsHomePageState createState() => _EsHomePageState();
}

class _EsHomePageState extends State<EsHomePage> {
  int _selectedIndex = 1;
  final List<Widget> _widgetOptions = <Widget>[
    Container(),
    EsOrderPage(),
    MenuPage(),
    EsVideoPage(),
    EsBusinessProfile(),
  ];

  final List<String> title = [
    'Home',
    'Orders',
    'Products',
    'Videos',
    'Profile',
  ];

  final List<IconData> icons = [
    Icons.chevron_left,
    Icons.shopping_basket,
    Icons.menu,
    Icons.play_circle_outline,
    Icons.store,
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushNamed(Router.homeRoute);
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: List.generate(
          title.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(icons[index]),
            title: Text(
              title[index],
            ),
          ),
        ),
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
