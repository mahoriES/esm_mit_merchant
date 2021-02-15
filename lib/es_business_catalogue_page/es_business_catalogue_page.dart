import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:foore/menu_page/add_menu_item_page.dart';
import '../app_translations.dart';
import 'es_business_catalogue_list_view.dart';
import 'es_business_catalogue_tree_view.dart';

class EsBusinessCataloguePage extends StatelessWidget {
  static const routeName = '/business_catalogue';

  EsBusinessCataloguePage();

  @override
  Widget build(BuildContext context) {
    viewItem(EsProduct product, {bool openSkuAddUpfront = false}) async {
      EsProductDetailPageParam esProductDetailPageParam =
          EsProductDetailPageParam(
              currentProduct: product, openSkuAddUpfront: openSkuAddUpfront);
      await Navigator.of(context).pushNamed(EsProductDetailPage.routeName,
          arguments: esProductDetailPageParam);
    }

    final List<String> tabTitles = [
      AppTranslations.of(context).text('business_catalogue_page_categories'),
      AppTranslations.of(context).text('business_catalogue_page_list_view'),
      AppTranslations.of(context).text('business_catalogue_page_sport_lights'),
      AppTranslations.of(context).text('business_catalogue_page_out_of_stock')
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
                      child: Text(
                        tabTitles[0],
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.list),
                      child: Text(
                        tabTitles[1],
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.star),
                      child: Text(
                        tabTitles[2],
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.outbond),
                      child: Text(
                        tabTitles[3],
                        style: TextStyle(fontSize: 11.0),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 10.toHeight),
              Divider(
                color: AppColors.greyishText,
                height: 0,
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    EsBusinessCatalogueTreeView(),
                    EsBusinessCatalogueListView(ProductFilters.listView),
                    EsBusinessCatalogueListView(ProductFilters.spotlights),
                    EsBusinessCatalogueListView(ProductFilters.outOfStock),
                  ],
                ),
              ),
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
          onPressed: () async {
            final product = await Navigator.of(context)
                .pushNamed(AddMenuItemPage.routeName);
            if (product != null) {
              viewItem(product, openSkuAddUpfront: true);
            }
          },
          child: Container(
            child: Text(
              AppTranslations.of(context).text('products_page_add_item'),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
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
