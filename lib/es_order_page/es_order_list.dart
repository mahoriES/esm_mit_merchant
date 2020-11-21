import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/bloc/es_orders.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/es_order_page/widgets/alert_dialogues.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';
import '../app_translations.dart';
import 'widgets/es_order_card.dart';

class EsOrderList extends StatefulWidget {
  final String orderStatus;
  const EsOrderList(this.orderStatus, {Key key}) : super(key: key);

  @override
  _EsOrderListState createState() => _EsOrderListState();
}

class _EsOrderListState extends State<EsOrderList> {
  EsOrdersBloc esOrdersBloc;

  @override
  void initState() {
    esOrdersBloc = Provider.of<EsOrdersBloc>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // popScreenAfterCompletion should be true when the callback is triggered from details screen
    // the details screen should be popped in case of succes.
    acceptItem(EsOrder order, {bool popScreenAfterCompletion = false}) async {
      var isAccepted = await OrdersAlertDialogs.showAcceptAlertDialog(
        order: order,
        esOrdersBloc: esOrdersBloc,
        context: context,
      );
      if (isAccepted == true) {
        if (popScreenAfterCompletion) Navigator.pop(context);
        esOrdersBloc.resetDataState();
      }
    }

    markReady(EsOrder order) async {
      var isAccepted = await OrdersAlertDialogs.showReadyAlertDialog(
        order: order,
        esOrdersBloc: esOrdersBloc,
        context: context,
      );
      if (isAccepted == true) {
        esOrdersBloc.resetDataState();
      }
    }

    cancelItem(EsOrder order, {bool popScreenAfterCompletion = false}) async {
      var isAccepted = await OrdersAlertDialogs.showCancelAlertDialog(
        order: order,
        esOrdersBloc: esOrdersBloc,
        context: context,
      );
      if (isAccepted == true) {
        if (popScreenAfterCompletion) Navigator.pop(context);
        esOrdersBloc.resetDataState();
      }
    }

    assignItem(EsOrder order) async {
      var isAccepted = await OrdersAlertDialogs.showAssignAlertDialog(
        order: order,
        esOrdersBloc: esOrdersBloc,
        context: context,
      );
      if (isAccepted == true) {
        esOrdersBloc.resetDataState();
      }
    }

    updatePaymentStatus(
      EsOrder order,
      String newStatus,
    ) async {
      var isAccepted = await OrdersAlertDialogs.showUpdateStatusAlertDialog(
        order: order,
        esOrdersBloc: esOrdersBloc,
        context: context,
        newStatus: newStatus,
      );
      if (isAccepted == true) {
        esOrdersBloc.resetDataState();
      }
    }

    updateOrder(
      EsOrder order,
      UpdateOrderPayload body, {
      bool popScreenAfterCompletion = false,
    }) async {
      var isAccepted = await OrdersAlertDialogs.showUpdateOrderAlertDialog(
        order: order,
        esOrdersBloc: esOrdersBloc,
        context: context,
        body: body,
      );
      if (isAccepted == true) {
        if (popScreenAfterCompletion) Navigator.pop(context);
        esOrdersBloc.resetDataState();
      }
    }

    markCompleted(EsOrder order) async {
      var isAccepted = await OrdersAlertDialogs.showCompleteAlertDialog(
        order: order,
        esOrdersBloc: esOrdersBloc,
        context: context,
      );
      if (isAccepted == true) {
        esOrdersBloc.resetDataState();
      }
    }

    return StreamBuilder<EsOrdersState>(
      stream: esOrdersBloc.esOrdersStateObservable,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        if (snapshot.data.ordersListStatus[widget.orderStatus].fetchingStatus ==
            DataState.IDLE) {
          esOrdersBloc.getOrders(widget.orderStatus);
          return Container();
        }
        if (snapshot.data.ordersListStatus[widget.orderStatus].fetchingStatus ==
            DataState.LOADING) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.ordersListStatus[widget.orderStatus].fetchingStatus ==
            DataState.FAILED) {
          return SomethingWentWrong(
            onRetry: () => esOrdersBloc.getOrders(widget.orderStatus),
          );
        }

        List<EsOrder> ordersList = snapshot.data
                .ordersListStatus[widget.orderStatus]?.ordersList?.results ??
            [];

        if (ordersList.isEmpty) {
          return EmptyList(
            titleText: AppTranslations.of(context).text("orders_page_no_orders_found"),
            subtitleText: "",
          );
        }

        return Container(
          color: AppColors.greyishText.withOpacity(0.1),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotification) {
              if (scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent) {
                esOrdersBloc.loadMore(widget.orderStatus);
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () => esOrdersBloc.getOrders(widget.orderStatus),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: SizeConfig().screenHeight,
                ),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ordersList.length,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.toHeight),
                        itemBuilder: (context, index) => EsOrderCard(
                          ordersList[index],
                          onAccept: ({bool popOnCompletion}) => acceptItem(
                            ordersList[index],
                            popScreenAfterCompletion: popOnCompletion ?? false,
                          ),
                          onMarkReady: () => markReady(ordersList[index]),
                          onMarkCompleted: () =>
                              markCompleted(ordersList[index]),
                          onCancel: ({bool popOnCompletion}) => cancelItem(
                            ordersList[index],
                            popScreenAfterCompletion: popOnCompletion ?? false,
                          ),
                          onAssign: () => assignItem(ordersList[index]),
                          onUpdatePaymentStatus: (newStatus) =>
                              updatePaymentStatus(
                            ordersList[index],
                            newStatus,
                          ),
                          onUpdateOrder: (body, {bool popOnCompletion}) =>
                              updateOrder(
                            ordersList[index],
                            body,
                            popScreenAfterCompletion: popOnCompletion ?? false,
                          ),
                        ),
                      ),
                      if (snapshot.data.loadMoreStatus ==
                          DataState.LOADING) ...[
                        SizedBox(height: 8.toHeight),
                        CircularProgressIndicator(),
                        SizedBox(height: 8.toHeight),
                      ],
                      if (snapshot.data.loadMoreStatus == DataState.FAILED) ...[
                        SizedBox(height: 8.toHeight),
                        SomethingWentWrong(
                          onRetry: () =>
                              esOrdersBloc.loadMore(widget.orderStatus),
                        ),
                        SizedBox(height: 8.toHeight),
                      ],
                      SizedBox(height: 20.toHeight),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
