import 'package:flutter/material.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/services/sizeconfig.dart';

import 'additional_charges_dialogue.dart';

class EsOrderDetailsChargesComponent extends StatefulWidget {
  final EsOrderDetailsResponse orderDetails;

  EsOrderDetailsChargesComponent(this.orderDetails);

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

  Widget getEditIconWidget(BuildContext context) {
    return Expanded(
      flex: 10,
      child: IconButton(
        padding: const EdgeInsets.all(0.0),
        icon: Icon(
          Icons.edit,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {},
      ),);
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
            Expanded(
              flex: 70,
              child: Text(
                _totalNumberOfItems.toString() +
                    '  Item' +
                    (_totalNumberOfItems > 1 ? 's' : ''),
              ),
            ),
            Expanded(
              flex: 20,
              child: Text(
                '\u{20B9} ${_itemCharges.toStringAsFixed(2)}',
              ),
            ),
            Expanded(
              flex: 10,
              child: SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: 10.toHeight),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(flex: 70, child: Text('Delivery Charges')),
            Expanded(flex: 20, child: Text('\u{20B9} $_deliveryCharges')),
            getEditIconWidget(context),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(flex: 70, child: Text('Other Charges')),
            Expanded(flex: 20, child: Text('\u{20B9} $_otherCharges')),
            getEditIconWidget(context),
          ],
        ),
        if (additionalChargesList.isEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(flex: 70, child: Text('Additional Charges')),
              Expanded(flex: 20, child: Text('\u{20B9} 0')),
              getEditIconWidget(context),
            ],
          ),
        ] else ...[
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
        SizedBox(height: 10.toHeight),
        Center(
          child: InkWell(
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 5.toWidth),
                  Text(
                    'Additional Charges',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              onTap: () async {
                var selectedCharge = await showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => AdditionalChargeDialogue(
                    dialogActionType: 0,
                    alreadySelectedCharges: additionalChargesList,
                  ),
                );
                if (selectedCharge != null &&
                    selectedCharge is Map<String, double>) {
                  setState(() {
                    additionalChargesList..addAll(selectedCharge);
                  });
                }
              },
            ),
          ),
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
            ),
          ],
        ),
      ],
    );
  }
}

enum AdditionalChargeType {
  deliveryCharge,
  extraCharge,
  packingCharge,
  serviceCharge,
}

class AdditionChargesMetaDataGenerator {

  static AdditionChargesMetaDataGenerator _instance;

  AdditionChargesMetaDataGenerator._internal();

  static AdditionChargesMetaDataGenerator getInstance() {
    if (_instance == null) {
      _instance = AdditionChargesMetaDataGenerator._internal();
    }
    return _instance;
  }

  static String backendKeyFromEnumValue(AdditionalChargeType chargeType) {

    switch(chargeType) {
      case AdditionalChargeType.deliveryCharge:
        return 'DELIVERY';
        break;
      case AdditionalChargeType.extraCharge:
        return 'EXTRA';
        break;
      case AdditionalChargeType.packingCharge:
        return 'PACKING';
        break;
      case AdditionalChargeType.serviceCharge:
        return 'SERVICE';
        break;
      default:
        return 'UNKNOWN';
    }
  }

  static String friendlyChargeNameFromEnumValue(AdditionalChargeType chargeType) {
    switch(chargeType) {
      case AdditionalChargeType.deliveryCharge:
        return 'Delivery Charges';
        break;
      case AdditionalChargeType.extraCharge:
        return 'Extra Charges';
        break;
      case AdditionalChargeType.packingCharge:
        return 'Packing Charges';
        break;
      case AdditionalChargeType.serviceCharge:
        return 'Service Charges';
        break;
      default:
        return 'Unknown Charge';
    }
  }

}