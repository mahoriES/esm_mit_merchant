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
      'Products',
    ];
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: tabTitles.length,
          child: Column(
            children: <Widget>[
              Container(
                child: TabBar(
                    isScrollable: true,
                    tabs: List.generate(
                      tabTitles.length,
                      (index) => Tab(
                        child: Text(
                          tabTitles[index],
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )),
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
