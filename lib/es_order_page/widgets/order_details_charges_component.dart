import 'package:flutter/material.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/services/sizeconfig.dart';

class EsOrderDetailsChargesComponent extends StatefulWidget {
  final EsOrderDetailsResponse orderDetails;
  final double spaceBetweenItems;
  EsOrderDetailsChargesComponent(
    this.orderDetails, {
    this.spaceBetweenItems = 10,
  });
  @override
  _EsOrderDetailsChargesComponentState createState() =>
      _EsOrderDetailsChargesComponentState();
}

class _EsOrderDetailsChargesComponentState
    extends State<EsOrderDetailsChargesComponent> {
  Map<String, double> additionalChargesList;

  @override
  void initState() {
    additionalChargesList = {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _itemCharges = 0;
    int _totalNumberOfItems = 0;

    for (int i = 0; i < widget.orderDetails.orderItems?.length; i++) {
      if (widget.orderDetails.orderItems[i].itemStatus !=
          CatalogueItemStatus.notPresent) {
        _itemCharges = _itemCharges +
            (widget.orderDetails.orderItems[i]?.unitPrice ?? 0) *
                (widget.orderDetails.orderItems[i].itemQuantity?.toDouble() ??
                    0);

        _totalNumberOfItems = _totalNumberOfItems +
            widget.orderDetails.orderItems[i].itemQuantity;
      }
    }

    double _deliveryCharges = (widget.orderDetails?.deliveryCharges ?? 0) / 100;
    double _otherCharges = (widget.orderDetails?.otherCharges ?? 0) / 100;

    double _additionalCharges = 0;
    additionalChargesList.forEach((key, value) {
      _additionalCharges = _additionalCharges + value;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery Charges'),
            Text('\u{20B9} $_deliveryCharges')
          ],
        ),
        SizedBox(height: widget.spaceBetweenItems.toHeight),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Other Charges'),
            Text('\u{20B9} $_otherCharges'),
          ],
        ),
        if (additionalChargesList.isEmpty) ...[
          SizedBox(height: widget.spaceBetweenItems.toHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Additional Charges'),
              Text('\u{20B9} 0'),
            ],
          ),
        ] else ...[
          SizedBox(height: widget.spaceBetweenItems.toHeight),
          ListView.separated(
            shrinkWrap: true,
            itemCount: additionalChargesList.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.toHeight),
            itemBuilder: (context, index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(additionalChargesList.keys.elementAt(index)),
                Text(
                    '\u{20B9} ${additionalChargesList.values.elementAt(index)}'),
              ],
            ),
          ),
        ],
        SizedBox(height: widget.spaceBetweenItems.toHeight),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _totalNumberOfItems.toString() +
                  '  Item' +
                  (_totalNumberOfItems > 1 ? 's' : ''),
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
            Text('Total Amount'),
            Text(
              '\u{20B9} ${(_itemCharges + _deliveryCharges + _otherCharges + _additionalCharges).toStringAsFixed(2)}',
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
