import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/bloc/es_business_catalogue.dart';
import 'package:foore/data/bloc/es_products.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/es_product_catalogue.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:provider/provider.dart';
import '../app_translations.dart';
import 'es_business_catalogue_list_view.dart';
import 'es_business_catalogue_search_view.dart';
import 'es_business_catalogue_tree_view.dart';

class EsBusinessCataloguePage extends StatefulWidget {
  static const routeName = '/business_catalogue';

  EsBusinessCataloguePage();

  static const List<Widget> tabIcons = [
    ImageIcon(AssetImage('assets/icons/categories.png')),
    ImageIcon(AssetImage('assets/icons/list-view.png')),
    ImageIcon(AssetImage('assets/icons/spotlights.png')),
    ImageIcon(AssetImage('assets/icons/out-of-stock.png')),
  ];

  @override
  _EsBusinessCataloguePageState createState() =>
      _EsBusinessCataloguePageState();
}

class _EsBusinessCataloguePageState extends State<EsBusinessCataloguePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewItem(EsProduct product, {bool openSkuAddUpfront = false}) async {
      EsProductDetailPageParam esProductDetailPageParam =
          EsProductDetailPageParam(
              currentProduct: product, openSkuAddUpfront: openSkuAddUpfront);
      await Navigator.of(context).pushNamed(EsProductDetailPage.routeName,
          arguments: esProductDetailPageParam);
      // TODO: Need to update with a better approach.
      Provider.of<EsBusinessCatalogueBloc>(context).reloadCategories();
      switch (_tabController.index) {
        case 0:
          Provider.of<EsProductsBloc>(context).resetDataState();
          break;
        case 1:
          Provider.of<EsProductsBloc>(context)
              .reloadProducts(ProductFilters.listView);
          break;
        case 2:
          Provider.of<EsProductsBloc>(context)
              .reloadProducts(ProductFilters.spotlights);
          break;
        case 3:
          Provider.of<EsProductsBloc>(context)
              .reloadProducts(ProductFilters.outOfStock);
          break;
      }
    }

    final List<String> tabTitles = [
      AppTranslations.of(context).text('business_catalogue_page_categories'),
      AppTranslations.of(context).text('business_catalogue_page_list_view'),
      AppTranslations.of(context).text('business_catalogue_page_spotlights'),
      AppTranslations.of(context).text('business_catalogue_page_out_of_stock')
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Hero(
          tag: EsBusinessCatalogueSearchView.searchBarHeroTag,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Material(
              child: TextField(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(EsBusinessCatalogueSearchView.routeName);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: false,
                  hintText: AppTranslations.of(context)
                      .text('business_catalogue_page_search_hint'),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              border: Border.all(
                color: Theme.of(context).primaryColor,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            margin: EdgeInsets.only(right: 8.0, top: 4, bottom: 4.0),
            child: IconButton(
              icon: Icon(Icons.add),
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                viewItem(null, openSkuAddUpfront: false);
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black26,
                indicatorColor: Colors.transparent,
                tabs: List.generate(
                  tabTitles.length,
                  (index) => Tab(
                    icon: EsBusinessCataloguePage.tabIcons[index],
                    child: Text(
                      tabTitles[index],
                      style: TextStyle(fontSize: 11.0),
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              color: AppColors.greyishText,
              height: 0,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
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
    );
  }
}
