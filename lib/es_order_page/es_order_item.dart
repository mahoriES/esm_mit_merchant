import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:url_launcher/url_launcher.dart';

class EsOrderItemWidget extends StatelessWidget {
  final EsOrder esOrder;
  final Function(EsOrder) onAccept;
  final Function(EsOrder) onMarkReady;
  final Function(EsOrder) onCancel;
  final Function(EsOrder) onAssign;
  final Function(EsOrder) onGetOrderItems;
  final Function(EsOrder, String) onUpdatePaymentStatus;
  final bool showStatus;
  const EsOrderItemWidget(
      {this.esOrder,
      this.onAccept,
      this.onCancel,
      this.onMarkReady,
      this.onAssign,
      this.onGetOrderItems,
      this.showStatus,
      this.onUpdatePaymentStatus});

  createOrderItemText() {
    return this
        .esOrder
        .orderItems
        .map((e) => Row(
              children: <Widget>[
                Text(e.productName),
                e.variationOption != null
                    ? Text("(" + e.variationOption + ")")
                    : Container(),
                Text("  x  "),
                Text(e.itemQuantity.toString()),
                Flexible(child: Container()),
                Text(e.itemTotal.toString())
              ],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        'Order #' + esOrder.orderShortNumber,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).textTheme.caption.color,
                              // fontWeight: FontWeight.w600
                            ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                      esOrder.dIsStatusNew
                          ? Icon(
                              Icons.new_releases,
                              size: 16,
                              color: Colors.orange,
                            ) //For new
                          : esOrder.dIsStatusCancelled
                              ? Icon(
                                  Icons.cancel,
                                  size: 16,
                                  color: Colors.red,
                                ) //For cancelled
                              : esOrder.dIsStatusComplete
                                  ? Icon(Icons.done_all, size: 16) //Complete
                                  : Icon(Icons.sync, size: 16),
                      SizedBox(
                        width: 4,
                      ),
                      Text(esOrder.dStatusString,
                          style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(esOrder.getCreatedTimeText(),
                      style: Theme.of(context).textTheme.caption),

                  SizedBox(
                    height: 12.0,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    color: Colors.grey[100],
                    child: GestureDetector(
                      onTap: () {
                        if (esOrder.orderItems == null) {
                          this.onGetOrderItems(this.esOrder);
                        }
                      },
                      child: Container(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Order Items",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                                color: ListTileTheme.of(context)
                                                    .textColor,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Flexible(child: Container())
                                    ],
                                  ),
                                  SizedBox(
                                    height: 4,
                                  )
                                ] +
                                (esOrder.orderItems != null
                                    ? this.createOrderItemText()
                                    : [
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.refresh)
                                          ],
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                      ])),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "Order Total",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: ListTileTheme.of(context).textColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                      Text(
                        esOrder.dOrderTotal,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: ListTileTheme.of(context).textColor,
                            ),
                      ),
                    ],
                  ),

                  UpiPaymentRow(
                    buildContext: context,
                    onClick: onUpdatePaymentStatus,
                    esOrder: esOrder,
                  ),

                  SizedBox(
                    height: 8.0,
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),

                  ////////////////////////////////////
                  ///// Cancellation Infomation
                  ////////////////////////////////////
                  ((esOrder.orderStatus == EsOrderStatus.CUSTOMER_CANCELLED) &&
                          (esOrder.cancellationNote != null) &&
                          (esOrder.cancellationNote.isNotEmpty))
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.announcement, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    "Cancellation Note",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                            color: ListTileTheme.of(context)
                                                .textColor,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                esOrder.cancellationNote,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    .copyWith(
                                      color:
                                          ListTileTheme.of(context).textColor,
                                    ),
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                            ])
                      : Container(),

                  ////////////////////////////////////
                  ///// Delivery Infomation
                  ////////////////////////////////////
                  Row(
                    children: <Widget>[
                      Icon(Icons.directions_bike, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Delivery Information",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: ListTileTheme.of(context).textColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    esOrder.dDeliveryType,
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: ListTileTheme.of(context).textColor,
                        ),
                  ),
                  esOrder.deliveryAddress != null
                      ? Text(
                          esOrder.deliveryAddress.prettyAddress != null
                              ? esOrder.deliveryAddress.prettyAddress
                              : '',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: Theme.of(context).textTheme.subtitle2.copyWith(
                                color:
                                    Theme.of(context).textTheme.caption.color,
                              ))
                      : SizedBox(),
                  SizedBox(
                    height: 16.0,
                  ),

                  ////////////////////////////////////
                  ///// Customer Infomation
                  ////////////////////////////////////
                  Row(
                    children: <Widget>[
                      Icon(Icons.person_outline, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Customer Information",
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: ListTileTheme.of(context).textColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4.0,
                  ),

                  Row(
                    children: <Widget>[
                      Text(
                        esOrder.customerName,
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                              color: ListTileTheme.of(context).textColor,
                            ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(),
                      ),
                      (esOrder.customerPhones != null) &&
                              (esOrder.customerPhones.length > 0)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: GestureDetector(
                                onTap: () {
                                  launch(
                                      ('tel://${esOrder.customerPhones[0]}'));
                                },
                                child: Text(
                                  esOrder.customerPhones[0],
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                          color: Colors.lightBlue,
                                          decoration: TextDecoration.underline),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  //SizedBox(
                  //  height: 4.0,
                  //),
                  (esOrder.customerNote != null)
                      ? Text(
                          esOrder.customerNote,
                          style: Theme.of(context).textTheme.subtitle2.copyWith(
                                color: ListTileTheme.of(context).textColor,
                              ),
                        )
                      : Container(),

                  SizedBox(
                    height: 16.0,
                  ),

                  Container(
                    child: esOrder.dIsNew
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              RaisedButton(
                                color:
                                    Theme.of(context).errorColor.withAlpha(150),
                                onPressed: () {
                                  this.onCancel(this.esOrder);
                                },
                                child: Text(
                                  'Cancel',
                                ),
                              ),
                              Flexible(child: Container()),
                              RaisedButton(
                                onPressed: () {
                                  this.onAccept(this.esOrder);
                                },
                                child: Text(
                                  'Accept',
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  Container(
                    child: esOrder.dIsPreparing
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(child: Container()),
                              RaisedButton(
                                onPressed: () {
                                  this.onMarkReady(this.esOrder);
                                },
                                child: Text(
                                  'Ready',
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  Container(
                    child: esOrder.dIsShowAssign
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(child: Container()),
                              RaisedButton(
                                onPressed: () {
                                  this.onAssign(this.esOrder);
                                },
                                child: Text(
                                  'Assign',
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Divider(
                    color: Colors.blue[200],
                    thickness: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpiPaymentRow extends StatelessWidget {
  final Function(EsOrder, String) onClick;
  final EsOrder esOrder;
  final BuildContext buildContext;

  const UpiPaymentRow({this.esOrder, this.onClick, this.buildContext});

  Widget getForStatusPending() {
    return Row(
      children: <Widget>[
        Icon(Icons.access_time, size: 16),
        SizedBox(width: 4),
        Text(
          EsOrderPaymentStatus.paymentString(esOrder.dPaymentStatus),
          style: Theme.of(buildContext).textTheme.subtitle2.copyWith(
                color: ListTileTheme.of(buildContext).textColor,
              ),
        ),
        Flexible(child: Container()),
        InkWell(
            onTap: () {
              onClick(esOrder, EsOrderPaymentStatus.APPROVED);
            },
            child: Text(
              "Mark Paid",
              style: TextStyle(
                  decoration: TextDecoration.underline, color: Colors.green),
            )),
      ],
    );
  }

  Widget getForStatusInitiated() {
    return Row(
      children: <Widget>[
        Icon(Icons.new_releases, size: 16, color: Colors.orange),
        SizedBox(width: 4),
        Text(
          EsOrderPaymentStatus.paymentString(esOrder.dPaymentStatus),
          style: Theme.of(buildContext).textTheme.subtitle2.copyWith(
                color: ListTileTheme.of(buildContext).textColor,
              ),
        ),
        Flexible(child: Container()),
        InkWell(
            onTap: () {
              onClick(esOrder, EsOrderPaymentStatus.APPROVED);
            },
            child: Text(
              "Approve Payment",
              style: TextStyle(
                  decoration: TextDecoration.underline, color: Colors.green),
            )),
      ],
    );
  }

  Widget getForStatusApproved() {
    return Row(
      children: <Widget>[
        Icon(Icons.done, size: 16, color: Colors.green),
        SizedBox(width: 4),
        Text(
          EsOrderPaymentStatus.paymentString(esOrder.dPaymentStatus),
          style: Theme.of(buildContext).textTheme.subtitle2.copyWith(
                color: ListTileTheme.of(buildContext).textColor,
              ),
        ),
        Flexible(child: Container()),
        InkWell(
            onTap: () {
              onClick(esOrder, EsOrderPaymentStatus.REJECTED);
            },
            child: Text(
              "Reject Payment",
              style: TextStyle(
                  decoration: TextDecoration.underline, color: Colors.red),
            )),
      ],
    );
  }

  Widget getForStatusRejected() {
    return Row(
      children: <Widget>[
        Icon(Icons.cancel, size: 16, color: Colors.red),
        SizedBox(width: 4),
        Text(
          EsOrderPaymentStatus.paymentString(esOrder.dPaymentStatus),
          style: Theme.of(buildContext).textTheme.subtitle2.copyWith(
                color: ListTileTheme.of(buildContext).textColor,
              ),
        ),
        Flexible(child: Container()),
        InkWell(
            onTap: () {
              onClick(esOrder, EsOrderPaymentStatus.REJECTED);
            },
            child: Text(
              "Approve Payment",
              style: TextStyle(
                  decoration: TextDecoration.underline, color: Colors.green),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return [EsOrderStatus.CREATED, EsOrderStatus.MERCHANT_UPDATED]
            .contains(esOrder.orderStatus)
        ? Container()
        : Container(
            padding: EdgeInsets.only(top: 8),
            child: esOrder.dPaymentStatus == EsOrderPaymentStatus.PENDING
                ? getForStatusPending()
                : esOrder.dPaymentStatus == EsOrderPaymentStatus.INITIATED
                    ? getForStatusInitiated()
                    : esOrder.dPaymentStatus == EsOrderPaymentStatus.APPROVED
                        ? getForStatusApproved()
                        : getForStatusRejected(),
          );
  }
}
