import 'package:flutter/material.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/widgets/es_select_business.dart';

import 'es_order_list.dart';

class EsOrderPage extends StatefulWidget {
  static const routeName = '/orders';
  final String title;

  EsOrderPage({this.title});

  @override
  _EsOrderPageState createState() => _EsOrderPageState();
}

class _EsOrderPageState extends State<EsOrderPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 5,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EsSelectBusiness(() {}),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(
                    child: Text(
                      'New',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Preparing',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Ready',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Delivery',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Container(),
              height: 40.0,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  EsOrderList(EsOrderStatus.CREATED),
                  EsOrderList(EsOrderStatus.MERCHANT_ACCEPTED),
                  EsOrderList(EsOrderStatus.REQUESTING_TO_DA),
                  EsOrderList(EsOrderStatus.COMPLETED),
                  EsOrderList(EsOrderStatus.READY_FOR_PICKUP),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
