import 'package:flutter/material.dart';
import 'package:foore/data/model/es_orders.dart';

class EsOrderItemWidget extends StatelessWidget {
  final EsOrder esOrder;
  final Function(EsOrder) onAccept;
  final Function(EsOrder) onMarkReady;
  final Function(EsOrder) onCancel;
  final Function(EsOrder) onAssign;
  final Function(EsOrder) onGetOrderItems;
  const EsOrderItemWidget(
      {this.esOrder,
      this.onAccept,
      this.onCancel,
      this.onMarkReady,
      this.onAssign,
      this.onGetOrderItems});

  createOrderItemText() {
    //List<String> itemStrings =
    //    this.esOrder.orderItems.map((e) => e.toString()).toList();
    //for (var st in itemStrings) {
    //  print(st);
    //}
    return this.esOrder.orderItems.map((e) => Text(e.toString())).toList();
    //return this.esOrder.orderItems.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 20,
        left: 20,
      ),
      child: GestureDetector(
        onTap: () {
          //this.onMarkReady(this.esOrder);
          //TODO: Remove this whole gesture detector
        },
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
                                color:
                                    Theme.of(context).textTheme.caption.color,
                                // fontWeight: FontWeight.w600
                              ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(),
                        ),
                        Text(esOrder.getCreatedTimeText(),
                            style: Theme.of(context).textTheme.caption),
                      ],
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Text(
                      esOrder.customerName,
                      style: Theme.of(context).textTheme.title.copyWith(
                            color: ListTileTheme.of(context).textColor,
                          ),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 2.0),
                            child: esOrder.dIsDelivery
                                ? Icon(
                                    Icons.label_important,
                                    size: 16,
                                    color: Colors.green,
                                  )
                                : null),
                        // Flexible(
                        //   child: Container(),
                        // ),
                        Text(
                          esOrder.dDeliveryType,
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                color: ListTileTheme.of(context).textColor,
                              ),
                        )
                      ],
                    ),
                    esOrder.deliveryAddress != null
                        ? Text(
                            esOrder.deliveryAddress.prettyAddress != null
                                ? esOrder.deliveryAddress.prettyAddress
                                : '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ))
                        : SizedBox(),
                    SizedBox(
                      height: 6.0,
                    ),
                    //Container(
                    //  padding: EdgeInsets.symmetric(vertical: 4),
                    //  width: double.infinity,
                    //  color: Colors.blueGrey[100],
                    //  child: Text(
                    //    "Details",
                    //    style: TextStyle(
                    //      fontSize: 22,
                    //    ),
                    //  ),
                    //),
                    SizedBox(
                      height: 12.0,
                    ),
                    Container(
                      child: esOrder.orderItems == null
                          ? FlatButton.icon(
                              onPressed: () {
                                this.onGetOrderItems(this.esOrder);
                              },
                              icon: Icon(Icons.details),
                              label: Text("show items"))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: this.createOrderItemText()),
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      esOrder.dOrderTotal,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: ListTileTheme.of(context).textColor,
                          ),
                    ),
                    Container(
                      child: esOrder.dIsNew
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                RaisedButton(
                                  onPressed: () {
                                    this.onAccept(this.esOrder);
                                  },
                                  child: Text(
                                    'Accept',
                                  ),
                                ),
                                SizedBox(width: 16),
                                RaisedButton(
                                  color: Theme.of(context)
                                      .errorColor
                                      .withAlpha(150),
                                  onPressed: () {
                                    this.onCancel(this.esOrder);
                                  },
                                  child: Text(
                                    'Cancel',
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
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
