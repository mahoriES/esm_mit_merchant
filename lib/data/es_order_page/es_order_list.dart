import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/bloc/es_orders.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

import 'es_order_item.dart';

class EsOrderList extends StatefulWidget {
  static const routeName = '/menu';

  EsOrderList({Key key}) : super(key: key);

  _EsOrderListState createState() => _EsOrderListState();
}

class _EsOrderListState extends State<EsOrderList> {
  EsOrdersBloc esOrdersBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esOrdersBloc == null) {
      this.esOrdersBloc = EsOrdersBloc(httpService, businessBloc);
    }
    this.esOrdersBloc.getOrders();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    acceptItem(EsOrder order) async {
      esOrdersBloc.getOrders();
    }

    markReady(EsOrder order) async {
      esOrdersBloc.getOrders();
    }

    cancelItem(EsOrder order) async {
      esOrdersBloc.getOrders();
    }

    assignItem(EsOrder order) async {
      esOrdersBloc.getOrders();
    }

    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<EsOrdersState>(
                stream: this.esOrdersBloc.esProductStateObservable,
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
                      onRetry: this.esOrdersBloc.getOrders,
                    );
                  } else if (snapshot.data.items.length == 0) {
                    return EmptyList(
                      titleText: 'No products found',
                      subtitleText: "Press 'Add item' to add new products",
                    );
                  } else {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                          this.esOrdersBloc.loadMore();
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
                            final currentProduct = snapshot.data.items[index];
                            return EsOrderItemWidget(
                              esOrder: currentProduct,
                              onAccept: acceptItem,
                              onMarkReady: markReady,
                              onCancel: cancelItem,
                              onAssign: assignItem,
                            );
                          }),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }
}
