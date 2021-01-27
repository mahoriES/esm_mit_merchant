import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_orders.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/widgets/response_dialog.dart';
import 'package:sprintf/sprintf.dart';

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
        content: Text(
            AppTranslations.of(context).text('orders_page_accept_popup_title')),
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
        content: Text(AppTranslations.of(context)
            .text('orders_page_ready_for_pickup_popup_title')),
        actions: <Widget>[
          RaisedButton(
            color: Theme.of(context).errorColor,
            child: Text(AppTranslations.of(context).text('orders_page_close')),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            child: Text(
                AppTranslations.of(context).text('orders_page_mark_as_ready')),
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
    @required bool isMerchantallowedToCompleteOrder,
  }) async {
    return _showDialogCommon(
      esOrdersBloc: esOrdersBloc,
      context: context,
      alertDialog: Center(
        child: _CompleteOrderDialog(
          order,
          esOrdersBloc,
          context,
          isMerchantallowedToCompleteOrder,
        ),
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
        title: Text(
            AppTranslations.of(context).text('orders_page_cancel_popup_title')),
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
                  content: Text(AppTranslations.of(context)
                      .text('orders_page_not_have_delivery_partners')),
                  actions: <Widget>[
                    RaisedButton(
                      color: Theme.of(context).errorColor,
                      child: Text(AppTranslations.of(context)
                          .text('orders_page_close')),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(false);
                      },
                    ),
                  ],
                );
              }

              return AlertDialog(
                title: Text(AppTranslations.of(context)
                    .text('orders_page_assign_order_popup_title')),
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
                    child: Text(
                        AppTranslations.of(context).text('orders_page_close')),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    },
                  ),
                  RaisedButton(
                    child: Text(
                        AppTranslations.of(context).text('orders_page_assign')),
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
        content: Text(
            AppTranslations.of(context).text('orders_page_update_popup_title')),
        actions: <Widget>[
          RaisedButton(
            color: Theme.of(context).errorColor,
            child: Text(AppTranslations.of(context).text('orders_page_close')),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
          ),
          RaisedButton(
            child: Text(AppTranslations.of(context)
                .text('orders_page_update_popup_button_update')),
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
  final bool isMerchantallowedToCompleteOrder;
  _CompleteOrderDialog(
    this.order,
    this.esOrdersBloc,
    this.dialogContext,
    this.isMerchantallowedToCompleteOrder,
  );

  @override
  __CompleteOrderDialogState createState() => __CompleteOrderDialogState();
}

class __CompleteOrderDialogState extends State<_CompleteOrderDialog> {
  bool isPaymentCompleted;

  get isShowPaymentConfirmationChecbox =>
      widget.order?.paymentInfo?.paymentStatus != EsOrderPaymentStatus.SUCCESS;

  @override
  void initState() {
    isPaymentCompleted = widget.order?.paymentInfo?.paymentStatus ==
        EsOrderPaymentStatus.SUCCESS;
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
      title: Text(AppTranslations.of(context)
          .text('orders_page_complete_order_popup_title')),
      content: !widget.isMerchantallowedToCompleteOrder
          ? Flexible(
              child: Text(
                AppTranslations.of(context)
                    .text('orders_page_rectrict_complete_order_message'),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isShowPaymentConfirmationChecbox)
                  Checkbox(
                      value: isPaymentCompleted,
                      onChanged: (isSelected) {
                        setState(() {
                          isPaymentCompleted = isSelected;
                        });
                      }),
                if (isShowPaymentConfirmationChecbox)
                  Expanded(
                    child: RichText(
                      softWrap: true,
                      text: TextSpan(
                        text: AppTranslations.of(context)
                            .text('orders_page_payment_confimation_cod_1'),
                        style: Theme.of(context).textTheme.subtitle1,
                        children: <TextSpan>[
                          TextSpan(
                            text: '${widget.order.dOrderTotal} ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: AppTranslations.of(context)
                                .text('orders_page_payment_confimation_cod_2'),
                          ),
                          TextSpan(
                            text: ' #${widget.order.orderShortNumber}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isShowPaymentConfirmationChecbox)
                  Expanded(
                    child: Text(
                      AppTranslations.of(context)
                          .text('orders_page_complete_confirmation_message'),
                    ),
                  ),
              ],
            ),
      actions: <Widget>[
        SizedBox(
          width: 8.0,
        ),
        RaisedButton(
          color: Theme.of(context).errorColor,
          child: Text(
            AppTranslations.of(context).text('orders_page_close'),
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
          child: Text(
              AppTranslations.of(context).text('orders_page_mark_completed')),
          color: Theme.of(context).primaryColor,
          onPressed: isPaymentCompleted &&
                  widget.isMerchantallowedToCompleteOrder
              ? () async {
                  if (isShowPaymentConfirmationChecbox) {
                    widget.esOrdersBloc.updateOrderPaymentStatus(
                      widget.order.orderId,
                      EsOrderPaymentStatus.APPROVED,
                      (EsOrder updtedOrder) {
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
                }
              : null,
        ),
        SizedBox(
          width: 8.0,
        )
      ],
    );
  }
}
