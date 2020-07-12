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

  final String status;

  EsOrderList(this.status, {Key key}) : super(key: key);

  _EsOrderListState createState() => _EsOrderListState();
}

class _EsOrderListState extends State<EsOrderList> {
  EsOrdersBloc esOrdersBloc;

  _showAcceptAlertDialog(EsOrder order, EsOrdersBloc esOrdersBloc) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return StreamBuilder<EsOrdersState>(
            stream: esOrdersBloc.esProductStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data.isSubmitting) {
                return AlertDialog(
                  content: Container(
                      height: 100,
                      child: Center(child: CircularProgressIndicator())),
                );
              }
              return AlertDialog(
                title: Container(),
                content: Text('Do you want to accept this order ?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.button,
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('Accept'),
                    onPressed: () {
                      esOrdersBloc.acceptOrder(order.orderId, (a) {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      }, () {
                        Navigator.of(context, rootNavigator: true).pop(false);
                      });
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  _showReadyAlertDialog(EsOrder order, EsOrdersBloc esOrdersBloc) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return StreamBuilder<EsOrdersState>(
            stream: esOrdersBloc.esProductStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data.isSubmitting) {
                return AlertDialog(
                  content: Container(
                      height: 100,
                      child: Center(child: CircularProgressIndicator())),
                );
              }
              return AlertDialog(
                title: Container(),
                content:
                    Text('Do you want to mark is order as Ready for pickup?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.button,
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('Mark as Ready'),
                    onPressed: () {
                      esOrdersBloc.markReady(order.orderId, (a) {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      }, () {
                        Navigator.of(context, rootNavigator: true).pop(false);
                      });
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  _showCancelAlertDialog(EsOrder order, EsOrdersBloc esOrdersBloc) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return StreamBuilder<EsOrdersState>(
            stream: esOrdersBloc.esProductStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data.isSubmitting) {
                return AlertDialog(
                  content: Container(
                      height: 100,
                      child: Center(child: CircularProgressIndicator())),
                );
              }
              return AlertDialog(
                title: Text('Choose a reason for cancellation'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data.cancellationReasons
                      .map(
                        (e) => ListTile(
                          onTap: () {
                            esOrdersBloc.cancelOrder(order.orderId, e, (a) {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(true);
                            }, () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(false);
                            });
                          },
                          title: Text(e),
                        ),
                      )
                      .toList(),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Close',
                      style: Theme.of(context).textTheme.button,
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  _showAssignAlertDialog(EsOrder order, EsOrdersBloc esOrdersBloc) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return StreamBuilder<EsOrdersState>(
            stream: esOrdersBloc.esProductStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data.isSubmitting) {
                return AlertDialog(
                  content: Container(
                      height: 100,
                      child: Center(child: CircularProgressIndicator())),
                );
              }

              if (snapshot.data.agents.length == 0) {
                return AlertDialog(
                  content: Text(
                      'You do not have any delivery partners. Please contact us if you need help onboarding delivery partners'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        'Close',
                        style: Theme.of(context).textTheme.button,
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(false);
                      },
                    ),
                  ],
                );
              }

              return AlertDialog(
                title: Text('Choose delivery partners'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.data.agents
                      .map(
                        (deliveryAgent) => CheckboxListTile(
                          value: deliveryAgent.dIsSelected,
                          onChanged: (value) {
                            esOrdersBloc.selectDeliveryAgent(
                                deliveryAgent, value);
                          },
                          title: Text(deliveryAgent.name ?? ''),
                        ),
                      )
                      .toList(),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Close',
                      style: Theme.of(context).textTheme.button,
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('Assign'),
                    onPressed: () {
                      esOrdersBloc.assignOrder(order.orderId, (a) {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      }, () {
                        Navigator.of(context, rootNavigator: true).pop(false);
                      });
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esOrdersBloc == null) {
      this.esOrdersBloc =
          EsOrdersBloc(widget.status, httpService, businessBloc);
    }
    // this.esOrdersBloc.getOrders();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    this.esOrdersBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    acceptItem(EsOrder order) async {
      var isAccepted = await _showAcceptAlertDialog(order, this.esOrdersBloc);
      if (isAccepted == true) {
        esOrdersBloc.getOrders();
      }
    }

    markReady(EsOrder order) async {
      var isAccepted = await _showReadyAlertDialog(order, this.esOrdersBloc);
      if (isAccepted == true) {
        esOrdersBloc.getOrders();
      }
    }

    cancelItem(EsOrder order) async {
      var isAccepted = await _showCancelAlertDialog(order, this.esOrdersBloc);
      if (isAccepted == true) {
        esOrdersBloc.getOrders();
      }
    }

    assignItem(EsOrder order) async {
      var isAccepted = await _showAssignAlertDialog(order, this.esOrdersBloc);
      if (isAccepted == true) {
        esOrdersBloc.getOrders();
      }
    }

    getOrderItems(EsOrder order) async {
      esOrdersBloc.getOrderItems(order.orderId);
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
                      titleText: 'No orders found',
                      subtitleText: "",
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
                              onGetOrderItems: getOrderItems,
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
