import 'package:flutter/material.dart';
import 'package:foore/auth_guard/auth_guard.dart';
import 'package:foore/data/bloc/people.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/es_business_profile/es_business_profile.dart';
import 'package:foore/es_order_page/es_order_page.dart';
import 'package:foore/home_page/app_drawer.dart';
import 'package:foore/home_page/home_page.dart';
import 'package:foore/intro_page/intro_page.dart';
import 'package:foore/menu_page/menu_page.dart';
import 'package:foore/onboarding_guard/onboarding_guard.dart';
import 'package:foore/widgets/es_select_business.dart';
import 'package:provider/provider.dart';

class EsHomePage extends StatefulWidget {
  static const routeName = '/';
  final HttpService httpServiceBloc;
  EsHomePage(this.httpServiceBloc);
  @override
  _EsHomePageState createState() => _EsHomePageState();
}

class _EsHomePageState extends State<EsHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      EsBusinessProfile(),
      EsOrderPage(),
      MenuPage(),
      AuthGuard(
        unauthenticatedPage: IntroPage(),
        child: OnboardingGuard(
          onboardingRequiredPage: MultiProvider(
            providers: [
              Provider<PeopleBloc>(
                builder: (context) => PeopleBloc(widget.httpServiceBloc),
                dispose: (context, value) => value.dispose(),
              ),
            ],
            child: HomePage(),
          ),
          child: MultiProvider(
            providers: [
              Provider<PeopleBloc>(
                builder: (context) => PeopleBloc(widget.httpServiceBloc),
                dispose: (context, value) => value.dispose(),
              ),
            ],
            child: HomePage(),
          ),
        ),
      ),
    ];

    return Scaffold(
      drawer: AppDrawer(),
      drawerEnableOpenDragGesture: false,
      appBar: _selectedIndex == 3
          ? AppBar()
          : _selectedIndex == 2
              ? AppBar(title: EsSelectBusiness(null, allowChange: false))
              : AppBar(title: EsSelectBusiness(null, allowChange: true)),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            title: Text(
              'Profile',
            ),
          ),
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
