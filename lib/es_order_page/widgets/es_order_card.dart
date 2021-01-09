import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_orders.dart';
import 'package:foore/data/constants/string_constants.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/es_order_page/es_order_details.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/utils/utils.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'custom_expansion_tile.dart';

class EsOrderCard extends StatefulWidget {
  final EsOrder esOrder;
  final Function({bool popOnCompletion}) onAccept;
  final Function() onMarkReady;
  final Function() onMarkCompleted;
  final Function({bool popOnCompletion}) onCancel;
  final Function() onAssign;
  final Function(String) onUpdatePaymentStatus;
  final Function(UpdateOrderPayload, {bool popOnCompletion}) onUpdateOrder;
  EsOrderCard(
    this.esOrder, {
    @required this.onAccept,
    @required this.onMarkReady,
    @required this.onMarkCompleted,
    @required this.onCancel,
    @required this.onAssign,
    @required this.onUpdatePaymentStatus,
    @required this.onUpdateOrder,
  });

  @override
  _EsOrderCardState createState() => _EsOrderCardState();
}

class _EsOrderCardState extends State<EsOrderCard> {
  final GlobalKey<CustomExpansionTileState> expansionTileKey =
      GlobalKey<CustomExpansionTileState>();
  EsOrdersBloc _esOrdersBloc;

  bool isExpanded;
  bool shouldGoToOrderDetails;

  @override
  void initState() {
    isExpanded = false;
    shouldGoToOrderDetails = false;
    _esOrdersBloc = Provider.of<EsOrdersBloc>(context, listen: false);
    super.initState();
  }

  _goToOrderDetails(EsOrderDetailsResponse orderDetailsResponse) {
    Navigator.of(context).pushNamed(
      EsOrderDetails.routeName,
      arguments: EsOrderDetailsParam(
        esOrderDetailsResponse: new EsOrderDetailsResponse.fromJson(
          orderDetailsResponse.toJson(),
          divideUnitPriceBy100: false,
        ),
        acceptOrder: (_context) async => widget.onAccept(popOnCompletion: true),
        cancelOrder: (_context) async => widget.onCancel(popOnCompletion: true),
        updateOrder: (_context, body) async => widget.onUpdateOrder(
          body,
          popOnCompletion: true,
        ),
      ),
    );
  }

  void _launchMapsUrl(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: AppTranslations.of(context)
              .text('orders_page_could_not_open_maps'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EsOrdersState>(
      stream: _esOrdersBloc.esOrdersStateObservable,
      builder: (context, snapshot) {
        Widget expandedView = const SizedBox.shrink();
        if (!snapshot.hasData) return Container();

        if (isExpanded) {
          if (snapshot
                  .data.orderDetailsFetchingStatus[widget.esOrder.orderId] ==
              DataState.FAILED) {
            expandedView = Container(
              height: 150.toHeight,
              child: SomethingWentWrong(
                onRetry: () =>
                    _esOrdersBloc.getOrderDetails(widget.esOrder.orderId),
              ),
            );
          } else if (snapshot
                  .data.orderDetailsFetchingStatus[widget.esOrder.orderId] ==
              DataState.SUCCESS) {
            expandedView = _CardExpandedView(
              snapshot.data.orderDetails[widget.esOrder.orderId],
            );
            // If 'Check' button is clicked then 'shouldGoToOrderDetails' will be true, in this case user should be redirected to the details view.
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (shouldGoToOrderDetails) {
                _goToOrderDetails(
                  snapshot.data.orderDetails[widget.esOrder.orderId],
                );
                shouldGoToOrderDetails = false;
              }
            });
          } else if (snapshot
                  .data.orderDetailsFetchingStatus[widget.esOrder.orderId] ==
              DataState.LOADING) {
            expandedView = Center(child: CircularProgressIndicator());
          } else {
            _esOrdersBloc.getOrderDetails(widget.esOrder.orderId);
            expandedView = Center(child: CircularProgressIndicator());
          }
        }

        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.toHeight),
          color: Colors.white,
          child: Column(
            children: [
              CustomExpansionTile(
                key: expansionTileKey,
                onExpansionChanged: (bool expanded) {
                  expansionTileKey.currentState.toggle();
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                trailing: SizedBox.shrink(),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ////////////////////////////////////
                    ///// Order Payment status.
                    ////////////////////////////////////
                    PaymentStatusRow(
                      onClick: (order, newStatus) =>
                          widget.onUpdatePaymentStatus(newStatus),
                      esOrder: widget.esOrder,
                    ),
                    SizedBox(height: 12.toHeight),

                    ////////////////////////////////////
                    ///// Order Number and status.
                    ////////////////////////////////////
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.of(context)
                                  .text('orders_page_order') +
                              ' #${widget.esOrder.orderShortNumber}',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color:
                                    Theme.of(context).textTheme.caption.color,
                              ),
                        ),
                        Expanded(child: Container()),
                        widget.esOrder.dIsStatusNew
                            ? Icon(
                                Icons.new_releases,
                                size: 16.toFont,
                                color: Colors.orange,
                              ) //For new
                            : widget.esOrder.dIsStatusCancelled
                                ? Icon(
                                    Icons.cancel,
                                    size: 16.toFont,
                                    color: Theme.of(context).errorColor,
                                  ) //For cancelled
                                : widget.esOrder.dIsStatusComplete
                                    ? Icon(
                                        Icons.done_all,
                                        size: 16.toFont,
                                      ) //Complete
                                    : Icon(
                                        Icons.sync,
                                        size: 16.toFont,
                                      ),
                        SizedBox(width: 4.toWidth),
                        Text(
                          widget.esOrder.dStatusString(context),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),

                    ////////////////////////////////////
                    ///// Order Time.
                    ////////////////////////////////////
                    Text(
                      "${widget.esOrder.getCreatedTimeText()}  (${Utils.getTimeDiffrence(widget.esOrder.created)})",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(height: 15.toHeight),

                    ////////////////////////////////////
                    ///// Order Total Price.
                    ////////////////////////////////////
                    Text(
                      widget.esOrder.dOrderTotal,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: 15.toHeight),

                    ////////////////////////////////////
                    ///// Cancellation Infomation
                    ////////////////////////////////////
                    if ((widget.esOrder.orderStatus ==
                            EsOrderStatus.CUSTOMER_CANCELLED) &&
                        (widget.esOrder.cancellationNote != null) &&
                        (widget.esOrder.cancellationNote.isNotEmpty)) ...[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Icon(Icons.announcement, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  AppTranslations.of(context)
                                      .text('orders_page_cancellation_note'),
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
                              widget.esOrder.cancellationNote,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                    color: ListTileTheme.of(context).textColor,
                                  ),
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                          ]),
                    ],

                    ////////////////////////////////////
                    ///// Order Delivery Info.
                    ////////////////////////////////////
                    if (widget.esOrder.deliveryAddress != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              child: Icon(
                                Icons.directions,
                                color: Theme.of(context).primaryColor,
                                size: 25.toHeight,
                              ),
                              onTap: () => _launchMapsUrl(
                                widget
                                    .esOrder.deliveryAddress.locationPoint.lat,
                                widget
                                    .esOrder.deliveryAddress.locationPoint.lon,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.toWidth),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.esOrder.dDeliveryType(context),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                        color:
                                            ListTileTheme.of(context).textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  widget.esOrder.deliveryAddress
                                              .prettyAddress !=
                                          null
                                      ? widget
                                          .esOrder.deliveryAddress.prettyAddress
                                      : '',
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2
                                      .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.toHeight),
                    ] else ...[
                      Text(
                        widget.esOrder.dDeliveryType(context),
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                              color: ListTileTheme.of(context).textColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ],
                ),
                children: [
                  ////////////////////////////////////
                  ///// expanded view
                  ////////////////////////////////////
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: expandedView is SizedBox ? 0 : 20.toHeight,
                    ),
                    child: expandedView,
                  ),
                ],
              ),

              ////////////////////////////////////
              ///// action buttons
              ////////////////////////////////////
              Container(
                margin: EdgeInsets.only(right: 10.toWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    if (widget.esOrder.dIsNew) ...[
                      RaisedButton(
                        onPressed: widget.onCancel,
                        color: Theme.of(context).errorColor,
                        child: Text(AppTranslations.of(context)
                            .text('orders_page_reject')),
                      ),
                      SizedBox(width: 20.toWidth),
                      RaisedButton(
                        onPressed: () {
                          expansionTileKey.currentState.expand();
                          shouldGoToOrderDetails = true;
                          setState(() {
                            isExpanded = true;
                          });
                        },
                        child: Text(AppTranslations.of(context)
                            .text('orders_page_check')),
                      ),
                    ],
                    if ((widget.esOrder.dIsReady ||
                            widget.esOrder.dIsShowInDelivry) &&
                        !widget.esOrder.dIsStatusCancelled) ...[
                      RaisedButton(
                        onPressed: widget.onMarkCompleted,
                        child: Text(AppTranslations.of(context)
                            .text('orders_page_mark_completed')),
                      ),
                    ],
                    widget.esOrder.dIsShowAssign
                        ? Row(
                            children: [
                              SizedBox(width: 20.toWidth),
                              RaisedButton(
                                onPressed: widget.onAssign,
                                child: Text(AppTranslations.of(context)
                                    .text('orders_page_assign')),
                              ),
                            ],
                          )
                        : widget.esOrder.dIsPreparing
                            ? RaisedButton(
                                onPressed: widget.onMarkReady,
                                child: Text(AppTranslations.of(context)
                                    .text('orders_page_ready')),
                              )
                            : SizedBox.shrink(),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _CardExpandedView extends StatelessWidget {
  final EsOrderDetailsResponse esOrderDetails;
  const _CardExpandedView(this.esOrderDetails);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.toWidth),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ////////////////////////////////////
                ///// Customer Infomation
                ////////////////////////////////////
                Text(
                  esOrderDetails.customerName,
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                        color: ListTileTheme.of(context).textColor,
                      ),
                ),
                if ((esOrderDetails.customerPhones != null) &&
                    (esOrderDetails.customerPhones.length > 0)) ...[
                  Row(
                    children: [
                      Text(
                        esOrderDetails.customerPhones[0],
                        style: Theme.of(context).textTheme.subtitle2.copyWith(),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          child: Icon(
                            Icons.call_rounded,
                            size: 25.toHeight,
                            color: Colors.lightBlue,
                          ),
                          onTap: () => launch(
                            StringConstants.callUrlLauncher(
                              esOrderDetails.customerPhones[0],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.toWidth),
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          child: Image.asset(
                            'assets/whatsapp.png',
                            height: 20.toHeight,
                            fit: BoxFit.cover,
                          ),
                          onTap: () => launch(
                            Platform.isIOS
                                ? StringConstants.whatsAppIosLauncher(
                                    esOrderDetails.customerPhones[0],
                                    StringConstants.whatsAppMessage(
                                        esOrderDetails.orderShortNumber,
                                        esOrderDetails.businessName),
                                  )
                                : StringConstants.whatsAppAndroidLauncher(
                                    esOrderDetails.customerPhones[0],
                                    StringConstants.whatsAppMessage(
                                        esOrderDetails.orderShortNumber,
                                        esOrderDetails.businessName),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                ////////////////////////////////////
                ///// Order Items List
                ////////////////////////////////////
                SizedBox(height: 20.toHeight),
                Row(
                  children: <Widget>[
                    Text(
                      AppTranslations.of(context)
                          .text('orders_page_order_items'),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: ListTileTheme.of(context).textColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Flexible(child: Container())
                  ],
                ),
                SizedBox(height: 4.toHeight),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: esOrderDetails.orderItems.length,
                  itemBuilder: (context, index) => Row(
                    children: <Widget>[
                      Text(esOrderDetails.orderItems[index].productName),
                      esOrderDetails.orderItems[index].variationOption != null
                          ? Text("(" +
                              esOrderDetails.orderItems[index].variationOption +
                              ")")
                          : Container(),
                      Text("  x  "),
                      Text(esOrderDetails.orderItems[index].itemQuantity
                          .toString()),
                      Flexible(child: Container()),
                      Text((esOrderDetails.orderItems[index].itemTotal ?? 'NA')
                          .toString())
                    ],
                  ),
                ),
                SizedBox(height: 4.toHeight),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: esOrderDetails.freeFormItems.length,
                  itemBuilder: (context, index) =>
                      Text(esOrderDetails.freeFormItems[index].skuName),
                ),

                ////////////////////////////////////
                ///// Payment Infomation
                ////////////////////////////////////
                SizedBox(height: 20.toHeight),
                Text(
                  AppTranslations.of(context)
                      .text('orders_page_payment_details'),
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: ListTileTheme.of(context).textColor,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.toHeight),
                _ChargesComponent(esOrderDetails),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PaymentStatusRow extends StatelessWidget {
  final Function(EsOrder, String) onClick;
  final EsOrder esOrder;

  const PaymentStatusRow({this.esOrder, this.onClick});

  IconData get paymentStatusIcon {
    final EsOrderPaymentInfo paymentInfo = esOrder.paymentInfo;
    IconData paymentStatusIcon = Icons.access_time;
    switch (paymentInfo.status) {
      // Old statuses
      case EsOrderPaymentStatus.INITIATED:
        paymentStatusIcon = Icons.new_releases;

        break;
      case EsOrderPaymentStatus.APPROVED:
        paymentStatusIcon = Icons.done;
        break;
      case EsOrderPaymentStatus.REJECTED:
        paymentStatusIcon = Icons.cancel;
        break;
      // New statuses
      case EsOrderPaymentStatus.SUCCESS:
        paymentStatusIcon = Icons.done;
        break;
      case EsOrderPaymentStatus.FAIL:
        paymentStatusIcon = Icons.warning;
        break;
      case EsOrderPaymentStatus.REFUNDED:
        paymentStatusIcon = Icons.undo;
        break;
    }
    return paymentStatusIcon;
  }

  Color getPaymentStatusIconColor(BuildContext context) {
    final EsOrderPaymentInfo paymentInfo = esOrder.paymentInfo;
    Color paymentStatusIconColor = Theme.of(context).errorColor;
    switch (paymentInfo.status) {
      // Old statuses
      case EsOrderPaymentStatus.INITIATED:
        paymentStatusIconColor = Colors.orange;

        break;
      case EsOrderPaymentStatus.APPROVED:
        paymentStatusIconColor = Theme.of(context).primaryColor;
        break;
      case EsOrderPaymentStatus.REJECTED:
        paymentStatusIconColor = Theme.of(context).errorColor;
        break;
      // New statuses
      case EsOrderPaymentStatus.SUCCESS:
        paymentStatusIconColor = Colors.green;
        break;
      case EsOrderPaymentStatus.FAIL:
        paymentStatusIconColor = Theme.of(context).errorColor;
        break;
      case EsOrderPaymentStatus.REFUNDED:
        paymentStatusIconColor = Colors.orange;
        break;
    }
    return paymentStatusIconColor;
  }

  String getDisplayablePaymentString(BuildContext context) {
    final EsOrderPaymentInfo paymentInfo = esOrder.paymentInfo;
    String paymentString =
        AppTranslations.of(context).text('orders_page_payemnt_pending');
    switch (paymentInfo.status) {
      // Old statuses
      case EsOrderPaymentStatus.INITIATED:
        paymentString =
            AppTranslations.of(context).text('orders_page_customer_paid');
        break;
      case EsOrderPaymentStatus.APPROVED:
        paymentString =
            AppTranslations.of(context).text('orders_page_payment_approved');
        break;
      case EsOrderPaymentStatus.REJECTED:
        paymentString =
            AppTranslations.of(context).text('orders_page_payment_rejected');
        break;
      // New statuses
      // Todo: Add translations.
      case EsOrderPaymentStatus.SUCCESS:
        paymentString =
            'Paid ${paymentInfo.dAmount} using ${paymentInfo.paymentMadeVia}';
        break;
      case EsOrderPaymentStatus.FAIL:
        paymentString = 'Payment Failed';
        break;
      case EsOrderPaymentStatus.REFUNDED:
        paymentString =
            'Refunded ${paymentInfo.dAmount} at ${paymentInfo.dTransactionTime}';
        break;
    }
    return paymentString;
  }

  @override
  Widget build(BuildContext context) {
    return [
      EsOrderStatus.CREATED,
      // Removed Merchant Updated status for this check.
      // EsOrderStatus.MERCHANT_UPDATED,
    ].contains(esOrder.orderStatus)
        ? Container()
        : Row(
            children: <Widget>[
              Icon(
                paymentStatusIcon,
                size: 16,
                color: getPaymentStatusIconColor(context),
              ),
              SizedBox(width: 4),
              Text(
                getDisplayablePaymentString(context),
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ],
          );
  }
}

class _ChargesComponent extends StatelessWidget {
  final EsOrderDetailsResponse orderDetails;
  const _ChargesComponent(this.orderDetails, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _itemCharges = 0;

    if (orderDetails.orderItems == null || orderDetails.orderItems.isEmpty) {
      orderDetails.orderItems = [];
    }

    for (int i = 0; i < orderDetails.orderItems?.length; i++) {
      if (orderDetails.orderItems[i].itemStatus !=
          CatalogueItemStatus.notPresent) {
        _itemCharges = _itemCharges +
            (orderDetails.orderItems[i]?.unitPrice ?? 0) *
                (orderDetails.orderItems[i].itemQuantity?.toDouble() ?? 0);
      }
    }

    double _deliveryCharges = (orderDetails?.deliveryCharges ?? 0) / 100;
    double _otherCharges = (orderDetails?.otherCharges ?? 0) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppTranslations.of(context)
                .text('orders_page_delivery_charges')),
            Text('\u{20B9} $_deliveryCharges')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppTranslations.of(context).text('orders_page_other_charges')),
            Text('\u{20B9} $_otherCharges'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              orderDetails.orderItems?.length.toString() +
                  ' ' +
                  AppTranslations.of(context).text('orders_page_item') +
                  (orderDetails.orderItems.length > 1 ? 's' : ''),
            ),
            Text(
              '\u{20B9} ${_itemCharges.toStringAsFixed(2)}',
            )
          ],
        ),
        Divider(
          color: Colors.grey[400],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppTranslations.of(context).text('orders_page_total_amount')),
            Text(
              '\u{20B9} ${(_itemCharges + _deliveryCharges + _otherCharges).toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ],
    );
  }
}
