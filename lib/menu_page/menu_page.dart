import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_products.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/es_product_detail_page/es_product_detail_page.dart';
import 'package:foore/widgets/empty_list.dart';

import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

import 'add_menu_item_page.dart';
import 'menu_item.dart';
import 'menu_searchbar.dart';

class MenuPage extends StatefulWidget {
  static const routeName = '/menu';

  MenuPage({Key key}) : super(key: key);

  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  EsProductsBloc esProductsBloc;

  @override
  void didChangeDependencies() {
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esProductsBloc == null) {
      this.esProductsBloc = EsProductsBloc(httpService, businessBloc);
    }
    this.esProductsBloc.getProducts();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    editItem(EsProduct product) async {
      EsProductDetailPageParam esProductDetailPageParam =
          EsProductDetailPageParam(
              currentProduct: product, openSkuAddUpfront: false);

      var result = await Navigator.of(context).pushNamed(
          EsProductDetailPage.routeName,
          arguments: esProductDetailPageParam);
      esProductsBloc.getProducts();
    }

    deleteItem(EsProduct product) async {}

    viewItem(EsProduct product, {bool openSkuAddUpfront = false}) async {
      EsProductDetailPageParam esProductDetailPageParam =
          EsProductDetailPageParam(
              currentProduct: product, openSkuAddUpfront: openSkuAddUpfront);
      var result = await Navigator.of(context).pushNamed(
          EsProductDetailPage.routeName,
          arguments: esProductDetailPageParam);
      esProductsBloc.getProducts();
    }

    return Scaffold(
      //appBar: EsSelectBusiness(esProductsBloc.getProductsFromSearch),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              MenuSearchBar(this.esProductsBloc),
              Expanded(
                child: StreamBuilder<EsProductsState>(
                    stream: this.esProductsBloc.esProductStateObservable,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      if (snapshot.data.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.data.isLoadingFailed) {
                        return SomethingWentWrong(
                          onRetry: this.esProductsBloc.getProducts,
                        );
                      } else if (snapshot.data.items.length == 0) {
                        return EmptyList(
                          titleText: AppTranslations.of(context)
                              .text('products_page_no_products_found'),
                          subtitleText: AppTranslations.of(context).text(
                              'products_page_no_products_found_description'),
                        );
                      } else {
                        return NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              this.esProductsBloc.loadMore();
                            }
                            return false;
                          },
                          child: ListView.builder(
                              padding: EdgeInsets.only(
                                bottom: 72,
                                // top: 30,
                              ),
                              itemCount: snapshot.data.items.length,
                              itemBuilder: (context, index) {
                                if (snapshot.data.items.length == index) {
                                  if (snapshot.data.isLoadingMore) {
                                    return Container(
                                      margin: EdgeInsets.all(4.0),
                                      height: 36,
                                      width: 36,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                                final currentProduct =
                                    snapshot.data.items[index];
                                return MenuItemWidget(
                                  esProduct: currentProduct,
                                  onEdit: editItem,
                                  onTap: viewItem,
                                  onDelete: deleteItem,
                                );
                              }),
                        );
                      }
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
          onPressed: () async {
            dynamic product = await Navigator.of(context)
                .pushNamed(AddMenuItemPage.routeName);
            if (product != null) {
              //Open product detail for recently added product
              debugPrint("Moving to product detail with add sku==true");
              viewItem(product, openSkuAddUpfront: true);
            } else {
              esProductsBloc.getProducts();
            }
          },
          child: Container(
            child: Text(
              AppTranslations.of(context).text('products_page_add_item'),
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
