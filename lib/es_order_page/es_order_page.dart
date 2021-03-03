import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/home_page/app_drawer.dart';
import 'package:foore/widgets/es_select_business.dart';
import '../app_translations.dart';
import 'es_order_list.dart';
import 'package:foore/services/sizeconfig.dart';

class EsOrderPage extends StatelessWidget {
  static const routeName = '/orders';
  final String title;

  EsOrderPage({this.title});

  @override
  Widget build(BuildContext context) {
    final List<String> tabTitles = [
      AppTranslations.of(context).text("orders_page_new"),
      AppTranslations.of(context).text("orders_page_accepted"),
      AppTranslations.of(context).text("orders_page_ready"),
      AppTranslations.of(context).text("orders_page_delivery"),
      AppTranslations.of(context).text("orders_page_all")
    ];
    return Scaffold(
      drawer: AppDrawer(),
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: EsSelectBusiness(
          null,
        ),
      ),
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
                    EsOrderList(EsOrderStatus.CREATED),
                    EsOrderList(EsOrderStatus.MERCHANT_ACCEPTED),
                    EsOrderList(EsOrderStatus.READY_FOR_PICKUP),
                    EsOrderList(EsOrderStatus.REQUESTING_TO_DA),
                    EsOrderList(EsOrderStatus.ALL_ORDERS),
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
