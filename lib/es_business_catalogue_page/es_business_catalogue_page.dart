import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/services/sizeconfig.dart';
import 'es_business_catalogue_list_view.dart';
import 'es_business_catalogue_tree_view.dart';

class EsBusinessCataloguePage extends StatelessWidget {
  static const routeName = '/business_catalogue';

  EsBusinessCataloguePage();

  @override
  Widget build(BuildContext context) {
    final List<String> tabTitles = [
      'Categories',
      'List View',
    ];
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: tabTitles.length,
          child: Column(
            children: <Widget>[
              Container(
                child: TabBar(
                  isScrollable: false,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black26,
                  indicatorColor: Colors.transparent,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.apps),
                      child: Text(tabTitles[0]),
                    ),
                    Tab(
                      icon: Icon(Icons.list),
                      child: Text(tabTitles[1]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.toHeight),
              Divider(
                color: AppColors.greyishText,
                height: 0,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    EsBusinessCatalogueTreeView(),
                    EsBusinessCatalogueListView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
