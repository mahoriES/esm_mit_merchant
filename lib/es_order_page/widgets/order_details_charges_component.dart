import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/services/sizeconfig.dart';

import '../es_order_details.dart';
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

  @override
  void dispose() {
    EsOrderDetails.chargesUpdated.value = false;
    super.dispose();
  }

  //This function is called at the initialisation phase and used to build
  // the UI for charges which are received from the backend.
  void buildAdditionalChargesStructure(EsOrderDetailsResponse orderDetails) {
    if (orderDetails.additionalChargesDetails == null ||
        orderDetails.additionalChargesDetails.isEmpty) return;
    orderDetails.additionalChargesDetails.forEach((element) {
      additionalChargesList.add(element);
    });
  }

  void deleteChargeLocally(String chargeKey) {
    EsOrderDetails.chargesUpdated.value = true;
    additionalChargesList
        .removeWhere((element) => element.chargeName == chargeKey);
    widget.orderDetails.additionalChargesDetails = additionalChargesList;
  }

  void addOrUpdateChargeLocally(AdditionalChargesDetails chargesDetails) {
    EsOrderDetails.chargesUpdated.value = true;
    deleteChargeLocally(chargesDetails.chargeName);
    additionalChargesList.add(chargesDetails);
    widget.orderDetails.additionalChargesDetails = additionalChargesList;
  }

  Widget getDeleteIconWidget(BuildContext context, String chargeKey) {
    return Expanded(
      flex: 5,
      child: IconButton(
        padding: const EdgeInsets.only(right: 0),
        icon: Icon(
          Icons.remove_circle,
          color: AppColors.iconColors,
        ),
        onPressed: () {
          setState(() {
            deleteChargeLocally(chargeKey);
          });
        },
      ),
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
    if (selectedCharge != null && selectedCharge is AdditionalChargesDetails) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 60,
              child: Text(
                _totalNumberOfItems.toString() +
                    '  Item' +
                    (_totalNumberOfItems > 1 ? 's' : ''),
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.w400),
              ),
            ),
            Expanded(
              flex: 30,
              child: Text(
                '\u{20B9} ${_itemCharges.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.w400),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              flex: 10,
              child: SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: 10.toHeight),
        Divider(
          color: AppColors.greyishText,
        ),
        if (additionalChargesList.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: additionalChargesList.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.toHeight),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: 8.toWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      flex: 63,
                      child: Text(
                        AdditionChargesMetaDataGenerator
                            .friendlyChargeNameFromKeyValue(
                                additionalChargesList[index].chargeName),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            .copyWith(fontWeight: FontWeight.w400),
                      )),
                  Expanded(
                    flex: 20,
                    child: TextFormField(
                      //This key is very important to refresh the values for the fields when charges are added/removed.
                      key: Key(additionalChargesList.length.toString()),
                      onChanged: (value) {
                        var valid = validateChargeValueInput(value);
                        //We make sure that the correct values is saved under the hood, so we don't accidentally, send invalid values to backend.
                        if (valid == null) {
                          EsOrderDetails.chargesUpdated.value = true;
                          setState(() {
                            additionalChargesList[index].value =
                                (double.parse(value) * 100).toInt();
                          });
                        } else {
                          //This case would handle all invalid inputs and would initialise explicitly the value for those charges as 0.
                          //This would guard us from anomalies which would creep in due to invalid inputs.
                          setState(() {
                            additionalChargesList[index].value = 0;
                            Fluttertoast.showToast(
                                msg:
                                    'Invalid ${AdditionChargesMetaDataGenerator.friendlyChargeNameFromKeyValue(additionalChargesList[index].chargeName)} value!');
                          });
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: (additionalChargesList[index].value / 100)
                          .toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2
                          .copyWith(fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        prefix: Padding(
                            padding: EdgeInsets.only(right: 3.toWidth),
                            child: Text('\u{20B9}')),
                      ),
                    ),
                  ),
                  Expanded(flex: 12, child: SizedBox.shrink()),
                  getDeleteIconWidget(
                      context, additionalChargesList[index].chargeName),
                ],
              ),
            ),
          ),
        ],
        if (additionalChargesList.length <
            AdditionChargesMetaDataGenerator.allKeyOptions.length) ...[
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
                    'Add Charges',
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
            Expanded(
                flex: 65,
                child: Text(
                  'Total Amount',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold),
                )),
            Expanded(
              flex: 35,
              child: Text(
                '\u{20B9} ${(_itemCharges + additionalChargesList.fold(0, (prev, next) => prev + next.value) / 100).toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ],
    );
  }

  dynamic validateChargeValueInput(String input) {
    if (input == '' || double.tryParse(input) == null) {
      return 'Invalid value';
    }
    return null;
  }
}

enum AdditionalChargeType {
  deliveryCharge,
  extraCharge,
  packingCharge,
  serviceCharge,
}

///This class acts as an interface between the backend keys for charges and user-friendly charges string
///by a 1 on 1 mapping between the both.

class AdditionChargesMetaDataGenerator {
  static AdditionChargesMetaDataGenerator _instance;

  AdditionChargesMetaDataGenerator._internal() {
    _instance = this;
  }

  factory AdditionChargesMetaDataGenerator() =>
      _instance ?? AdditionChargesMetaDataGenerator._internal();

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
        return 'OTHER';
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
        return 'Other Charge';
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
        return 'Other Charge';
    }
  }
}
