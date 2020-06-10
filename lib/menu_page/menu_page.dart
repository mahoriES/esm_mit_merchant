import 'package:flutter/material.dart';
import 'package:foore/home_page/app_drawer.dart';

import 'add_menu_item_page.dart';
import 'menu_item.dart';
import 'menu_searchbar.dart';

class MenuPage extends StatefulWidget {
  static const routeName = '/menu';

  MenuPage({Key key}) : super(key: key);

  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
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
          'Menu',
        ),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: 72,
                      // top: 30,
                    ),
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return MenuSearchBar();
                      }
                      return MenuItemWidget(name: 'name');
                    }),
              )
            ],
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
          onPressed: () {
            Navigator.of(context).pushNamed(AddMenuItemPage.routeName);
          },
          child: Container(
            child: Text(
              'Add item',
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
