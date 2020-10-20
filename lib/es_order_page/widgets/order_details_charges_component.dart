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
  List<AdditionalChargesDetails> additionalChargesList;

  @override
  void initState() {
    additionalChargesList = List<AdditionalChargesDetails>();
    buildAdditionalChargesStructure(widget.orderDetails);
    super.initState();
  }

  void buildAdditionalChargesStructure(EsOrderDetailsResponse orderDetails) {
    if (orderDetails.additionalChargesDetails == null ||
        orderDetails.additionalChargesDetails.isEmpty) return;
    orderDetails.additionalChargesDetails.forEach((element) {
      additionalChargesList.add(element);
    });
  }

  void deleteChargeLocally(String chargeKey) {

    additionalChargesList.removeWhere((element) =>
        element.chargeName ==
        chargeKey);
  }

  void addOrUpdateChargeLocally(AdditionalChargesDetails chargesDetails) {
    deleteChargeLocally(chargesDetails.chargeName);
    additionalChargesList.add(chargesDetails);
  }

  Widget getEditIconWidget(BuildContext context, String chargeKey) {
    return Expanded(
      flex: 10,
      child: IconButton(
        padding: const EdgeInsets.all(0.0),
        icon: Icon(
          Icons.edit,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () {
          showEditChargeActionSheet(chargeKey);
        },
      ),
    );
  }

  void showEditChargeActionSheet(String chargeKey) {
    String chargeName =
        AdditionChargesMetaDataGenerator.friendlyChargeNameFromKeyValue(
            chargeKey);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                  leading: new Icon(Icons.edit),
                  title: new Text('Edit $chargeName'),
                  onTap: () {
                    Navigator.pop(bc);
                    showAdditionalChargeDialog(1, chargeName: chargeKey);
                  }),
              new ListTile(
                leading: new Icon(Icons.cancel_outlined),
                title: new Text('Delete $chargeName'),
                onTap: () {
                  Navigator.pop(bc);
                  setState(() {
                    deleteChargeLocally(chargeKey);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showAdditionalChargeDialog(int type, {String chargeName}) async {
    List<String> availableCharges = [];
    if (type == 0) {
      List addedCharges =
          additionalChargesList.map((e) => e.chargeName).toList();
      availableCharges = AdditionChargesMetaDataGenerator.allKeyOptions
          .toSet()
          .difference(addedCharges.toSet())
          .toList();
    }
    debugPrint('Available charges ${availableCharges.toString()}');
    var selectedCharge = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AdditionalChargeDialogue(
        dialogActionType: type,
        toBeEditedChargeName: type == 1 ? chargeName : null,
        availableChargesOptions: availableCharges,
      ),
    );
    if (selectedCharge != null &&
        selectedCharge is AdditionalChargesDetails) {
      setState(() {
        addOrUpdateChargeLocally(selectedCharge);
      });
    }
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
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              flex: 10,
              child: SizedBox.shrink(),
            ),
          ],
        ),
        if (additionalChargesList.isNotEmpty) ...[
          SizedBox(height: 10.toHeight),
          ListView.separated(
            shrinkWrap: true,
            itemCount: additionalChargesList.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.toHeight),
            itemBuilder: (context, index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 70,
                    child: Text(AdditionChargesMetaDataGenerator
                        .friendlyChargeNameFromKeyValue(
                            additionalChargesList[index].chargeName))),
                Expanded(
                  flex: 20,
                  child: Text(
                      '\u{20B9} ${(additionalChargesList[index].value / 100).toStringAsFixed(2)}'),
                ),
                getEditIconWidget(
                    context, additionalChargesList[index].chargeName),
              ],
            ),
          ),
        ],
        if (additionalChargesList.length < 4) ...[
          SizedBox(height: 10.toHeight),
          Center(
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
                showAdditionalChargeDialog(0);
              },
            ),
          ),
        ],
        Divider(
          color: Colors.grey[400],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total Amount'),
            Text(
              '\u{20B9} ${(_itemCharges + _deliveryCharges + _otherCharges).toStringAsFixed(2)}',
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

  static String keyFromEnumValue(AdditionalChargeType chargeType) {
    switch (chargeType) {
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

  static List<String> get allKeyOptions =>
      ['DELIVERY', 'EXTRA', 'PACKING', 'SERVICE'];

  static String friendlyChargeNameFromEnumValue(
      AdditionalChargeType chargeType) {
    switch (chargeType) {
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

  static String friendlyChargeNameFromKeyValue(String key) {
    switch (key) {
      case 'DELIVERY':
        return 'Delivery Charges';
        break;
      case 'EXTRA':
        return 'Extra Charges';
        break;
      case 'PACKING':
        return 'Packing Charges';
        break;
      case 'SERVICE':
        return 'Service Charges';
        break;
      default:
        return 'Unknown Charge';
    }
  }
}
