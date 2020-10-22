import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/model/es_orders.dart';
import 'es_order_list.dart';
import 'package:foore/services/sizeconfig.dart';

class EsOrderPage extends StatelessWidget {
  static const routeName = '/orders';
  final String title;

  EsOrderPage({this.title});
  final List<String> tabTitles = [
    'New',
    'Preparing',
    'Ready',
    'Delivery',
    'All'
  ];

  @override
  Widget build(BuildContext context) {
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
                    EsOrdersList(EsOrderStatus.CREATED),
                    EsOrdersList(EsOrderStatus.MERCHANT_ACCEPTED),
                    EsOrdersList(EsOrderStatus.READY_FOR_PICKUP),
                    EsOrdersList(EsOrderStatus.REQUESTING_TO_DA),
                    EsOrdersList(EsOrderStatus.ALL_ORDERS),
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
