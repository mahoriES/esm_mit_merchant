import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      builder: (BuildContext context) {
        return StreamBuilder<EsOrdersState>(
          stream: esOrdersBloc.esOrdersStateObservable,
          builder: (context, snapshot) {
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
      alertDialog: AlertDialog(
        title: Text('Do you want to mark this order as completed?'),
        content: Column(
          children: [
            RadioListTile(
              value: null,
              groupValue: null,
              onChanged: null,
            )
          ],
        ),
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
            child: Text('Mark as Completed'),
            onPressed: () {
              esOrdersBloc.markComplete(order.orderId, () {
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

  static showCancelAlertDialog({
    @required EsOrder order,
    @required EsOrdersBloc esOrdersBloc,
    @required BuildContext context,
  }) async {
    final List<String> cancellationReasons = [
      'Kitchen full',
      'Item out of stock',
      'No delivery person',
      'Closing time',
      'Other'
    ];
    return _showDialogCommon(
      esOrdersBloc: esOrdersBloc,
      context: context,
      alertDialog: AlertDialog(
        title: Text('Choose a reason for cancellation'),
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
            child: Text(newStatus),
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
    @required UpdateOrderItemsPayload body,
    @required BuildContext context,
  }) async {
    return await _showDialogCommon(
      context: context,
      esOrdersBloc: esOrdersBloc,
      alertDialog: AlertDialog(
        title: Container(),
        content: Text('Do you want to update this order ?'),
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
            child: Text('Update'),
            onPressed: () {
              esOrdersBloc.updateOrderItems(
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
