import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/app_translations_bloc.dart';
import 'package:foore/data/bloc/es_orders.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/widgets/response_dialog.dart';

class OrdersAlertDialogs {
  static _showDialogCommon<bool>({
    @required EsOrdersBloc esOrdersBloc,
    @required BuildContext context,
    @required Widget alertDialog,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // user must tap button for close dialog!
      builder: (BuildContext dialogContext) {
        return StreamBuilder<EsOrdersState>(
          stream: esOrdersBloc.esOrdersStateObservable,
          builder: (dialogContext, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            if (snapshot.data.submittingStatus == DataState.LOADING) {
              return AlertDialog(
                content: Container(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
            return alertDialog;
          },
        );
      },
    );
  }

  static showAcceptAlertDialog({
    @required EsOrder order,
    @required EsOrdersBloc esOrdersBloc,
    @required BuildContext context,
  }) async {
    return _showDialogCommon(
      esOrdersBloc: esOrdersBloc,
      context: context,
      alertDialog: AlertDialog(
        title: Container(),
        content: Text(AppTranslations.of(context).text('orders_page_accept_popup_title')),
        actions: <Widget>[
          RaisedButton(
            color: Theme.of(context).errorColor,
            child: Text(AppTranslations.of(context).text('orders_page_cancel')),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
          ),
          RaisedButton(
            child: Text(AppTranslations.of(context).text('orders_page_accept')),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              esOrdersBloc.acceptOrder(
                order.orderId,
                (a) {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                (error) {
                  Navigator.of(context, rootNavigator: true).pop(false);
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ResponseDialogue(error ?? 'something went wrong'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  static showReadyAlertDialog({
    @required EsOrder order,
    @required EsOrdersBloc esOrdersBloc,
    @required BuildContext context,
  }) async {
    return _showDialogCommon(
      esOrdersBloc: esOrdersBloc,
      context: context,
      alertDialog: AlertDialog(
        title: Container(),
        content: Text('Do you want to mark this order as Ready for pickup?'),
        actions: <Widget>[
          RaisedButton(
            color: Theme.of(context).errorColor,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            child: Text('Mark as Ready'),
            onPressed: () {
              esOrdersBloc.markReady(order.orderId, (a) {
                Navigator.of(context, rootNavigator: true).pop(true);
              }, (error) {
                Navigator.of(context, rootNavigator: true).pop(false);
                showDialog(
                  context: context,
                  builder: (context) =>
                      ResponseDialogue(error ?? 'something went wrong'),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  static showCompleteAlertDialog({
    @required EsOrder order,
    @required EsOrdersBloc esOrdersBloc,
    @required BuildContext context,
  }) async {
    return _showDialogCommon(
      esOrdersBloc: esOrdersBloc,
      context: context,
      alertDialog: Center(
        child: _CompleteOrderDialog(order, esOrdersBloc, context),
      ),
    );
  }

  static showCancelAlertDialog({
    @required EsOrder order,
    @required EsOrdersBloc esOrdersBloc,
    @required BuildContext context,
  }) async {
    final List<String> cancellationReasons = [
      AppTranslations.of(context).text('orders_page_kitchen_full'),
      AppTranslations.of(context).text("orders_page_item_out_of_stock"),
      AppTranslations.of(context).text("orders_page_no_delivery_person"),
      AppTranslations.of(context).text("orders_page_closing_time"),
      AppTranslations.of(context).text("orders_page_other")
    ];
    return _showDialogCommon(
      esOrdersBloc: esOrdersBloc,
      context: context,
      alertDialog: AlertDialog(
        title: Text(AppTranslations.of(context).text('orders_page_cancel_popup_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: cancellationReasons
              .map(
                (e) => ListTile(
                  onTap: () {
                    esOrdersBloc.cancelOrder(
                      order.orderId,
                      e,
                      (a) {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      },
                      (error) {
                        Navigator.of(context, rootNavigator: true).pop(false);
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ResponseDialogue(error ?? 'something went wrong'),
                        );
                      },
                    );
                  },
                  title: Text(e),
                ),
              )
              .toList(),
        ),
        actions: <Widget>[
          RaisedButton(
            color: Theme.of(context).errorColor,
            child: Text(AppTranslations.of(context).text('orders_page_close')),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
          ),
        ],
      ),
    );
  }

  static showAssignAlertDialog({
    @required EsOrder order,
    @required EsOrdersBloc esOrdersBloc,
    @required BuildContext context,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return StreamBuilder<EsOrdersState>(
            stream: esOrdersBloc.esOrdersStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data.agentsFetchingStatus == DataState.LOADING) {
                return AlertDialog(
                  content: Container(
                      height: 100,
                      child: Center(child: CircularProgressIndicator())),
                );
              }

              if (snapshot.data.agents == null ||
                  snapshot.data.agents.isEmpty) {
                return AlertDialog(
                  content: Text(
                      'You do not have any delivery partners. Please contact us if you need help onboarding delivery partners'),
                  actions: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).errorColor,
                      child: Text(AppTranslations.of(context).text('orders_page_close')),
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
                  RaisedButton(
                    color: Theme.of(context).errorColor,
                    child: Text(AppTranslations.of(context).text('orders_page_close')),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    },
                  ),
                  RaisedButton(
                    child: Text(AppTranslations.of(context).text('orders_page_assign')),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      esOrdersBloc.assignOrder(order.orderId, (a) {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      }, (error) {
                        Navigator.of(context, rootNavigator: true).pop(false);
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ResponseDialogue(error ?? 'something went wrong'),
                        );
                      });
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  static showUpdateStatusAlertDialog({
    @required String newStatus,
    @required EsOrder order,
    @required EsOrdersBloc esOrdersBloc,
    @required BuildContext context,
  }) async {
    return await _showDialogCommon(
      context: context,
      esOrdersBloc: esOrdersBloc,
      alertDialog: AlertDialog(
        title: Container(),
        content: Text(
            'Do you want to update payment status of order to $newStatus?'),
        actions: <Widget>[
          RaisedButton(
            color: Theme.of(context).errorColor,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
          ),
          RaisedButton(
            child: Text(newStatus),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              esOrdersBloc.updateOrderPaymentStatus(order.orderId, newStatus,
                  (a) {
                Navigator.of(context, rootNavigator: true).pop(true);
              }, (error) {
                Navigator.of(context, rootNavigator: true).pop(false);
                showDialog(
                  context: context,
                  builder: (context) =>
                      ResponseDialogue(error ?? 'something went wrong'),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  static showUpdateOrderAlertDialog({
    @required EsOrder order,
    @required EsOrdersBloc esOrdersBloc,
    @required UpdateOrderPayload body,
    @required BuildContext context,
  }) async {
    return await _showDialogCommon(
      context: context,
      esOrdersBloc: esOrdersBloc,
      alertDialog: AlertDialog(
        title: Container(),
        content: Text('Do you want to update this order ?'),
        actions: <Widget>[
          RaisedButton(
            color: Theme.of(context).errorColor,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
          ),
          RaisedButton(
            child: Text('Update'),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              esOrdersBloc.updateOrder(
                order.orderId,
                (a) {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                (error) {
                  Navigator.of(context, rootNavigator: true).pop(false);
                  showDialog(
                    context: context,
                    builder: (context) => ResponseDialogue(
                      error ?? 'something went wrong',
                    ),
                  );
                },
                body,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CompleteOrderDialog extends StatefulWidget {
  final EsOrder order;
  final EsOrdersBloc esOrdersBloc;
  final BuildContext dialogContext;
  _CompleteOrderDialog(
    this.order,
    this.esOrdersBloc,
    this.dialogContext,
  );

  @override
  __CompleteOrderDialogState createState() => __CompleteOrderDialogState();
}

class __CompleteOrderDialogState extends State<_CompleteOrderDialog> {
  String radioValue;
  @override
  void initState() {
    print('initially ${widget.order.dPaymentStatus}');
    if (widget.order.dPaymentStatus == EsOrderPaymentStatus.APPROVED ||
        widget.order.dPaymentStatus == EsOrderPaymentStatus.REJECTED) {
      radioValue = widget.order.dPaymentStatus;
    } else
      radioValue = "NA";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _markAsCompleted() {
    widget.esOrdersBloc.markComplete(widget.order.orderId, () {
      Navigator.of(widget.dialogContext, rootNavigator: true).pop(true);
    }, (error) {
      Navigator.of(widget.dialogContext, rootNavigator: true).pop(false);
      showDialog(
        context: widget.dialogContext,
        builder: (context) => ResponseDialogue(error ?? 'something went wrong'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('Complete Order'),
      content: Column(
        children: [
          RichText(
            text: TextSpan(
              text: 'Did you receive the payment of ',
              style: Theme.of(context).textTheme.subtitle1,
              children: <TextSpan>[
                TextSpan(
                  text: '${widget.order.dOrderTotal} ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'for order ',
                ),
                TextSpan(
                  text: ' #${widget.order.orderShortNumber}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Radio(
              value: EsOrderPaymentStatus.APPROVED,
              visualDensity: VisualDensity.compact,
              groupValue: radioValue,
              onChanged: (v) {
                setState(() {
                  radioValue = v;
                });
              },
            ),
            title: Text('Yes'),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            leading: Radio(
              value: EsOrderPaymentStatus.REJECTED,
              visualDensity: VisualDensity.compact,
              groupValue: radioValue,
              onChanged: (v) {
                setState(() {
                  radioValue = v;
                });
              },
            ),
            title: Text('No'),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            leading: Radio(
              value: "NA",
              visualDensity: VisualDensity.compact,
              groupValue: radioValue,
              onChanged: (v) {
                setState(() {
                  radioValue = v;
                });
              },
            ),
            title: Text("Don't Know"),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: <Widget>[
        RaisedButton(
          color: Theme.of(context).errorColor,
          child: Text(
            'Cancel',
            style: Theme.of(context)
                .textTheme
                .button
                .copyWith(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(false);
          },
        ),
        RaisedButton(
          child: Text('Mark Completed'),
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            if (radioValue != widget.order.dPaymentStatus &&
                radioValue != "NA") {
              widget.esOrdersBloc.updateOrderPaymentStatus(
                widget.order.orderId,
                radioValue,
                (a) {
                  _markAsCompleted();
                },
                (error) {
                  Navigator.of(widget.dialogContext, rootNavigator: true)
                      .pop(false);
                  showDialog(
                    context: widget.dialogContext,
                    builder: (context) =>
                        ResponseDialogue(error ?? 'something went wrong'),
                  );
                },
              );
            } else
              _markAsCompleted();
          },
        ),
      ],
    );
  }
}
