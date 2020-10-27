import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/services/sizeconfig.dart';
import 'order_details_charges_component.dart';

///This is a configurable dialog box shown to add/edit additional charge(s).
///For charges not added yet, user may choose the charge type from dropdown &
///for already added charges, user can simply change the value for the charge.

class AdditionalChargeDialogue extends StatefulWidget {
  ///The list [availableChargesOptions] holds those charges which have not been
  ///added yet, and skips the ones which have been added, as they can only be either
  ///deleted or edited.
  final List<String> availableChargesOptions;

  ///The value [dialogActionType] can have 2 values - i) 0 when the action is meant to add new charges
  ///ii) 1 when an existing charge's value needs to be modified. Passed only when [dialogActionType] is 0.
  final int dialogActionType;

  ///[toBeEditedChargeName] holds the name of the charge whose value has to be changed. This value is passed
  ///only when [dialogActionType] is 1.
  final String toBeEditedChargeName;

  AdditionalChargeDialogue({
    @required this.dialogActionType,
    this.availableChargesOptions,
    this.toBeEditedChargeName,
  });

  @override
  _AdditionalChargeDialogueState createState() =>
      _AdditionalChargeDialogueState();
}

class _AdditionalChargeDialogueState extends State<AdditionalChargeDialogue> {
  FocusNode focusNode = new FocusNode();
  int dropdownValue;
  TextEditingController priceController = new TextEditingController();

  @override
  void initState() {
    dropdownValue = 0;
    super.initState();
  }

  @override
  void dispose() {
    priceController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.dialogActionType == 0
        ? 'Add a Charge'
        : 'Edit ${AdditionChargesMetaDataGenerator.friendlyChargeNameFromKeyValue(widget.toBeEditedChargeName)}';
    return GestureDetector(
      onTap: () {
        focusNode?.unfocus();
      },
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.toWidth),
            child: Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              padding: EdgeInsets.symmetric(
                horizontal: 20.toWidth,
                vertical: 10.toHeight,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.toWidth),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                        color: AppColors.blackTextColor, fontSize: 20.toFont),
                  ),
                  fineSeparator,
                  Row(
                    children: [
                      Expanded(
                          flex: 60,
                          child: widget.dialogActionType == 0
                              ? buildDropdownMenu
                              : editChargeNameLabel),
                      Expanded(flex: 10, child: SizedBox.shrink()),
                      Expanded(
                          flex: 30,
                          child: TextField(
                              maxLengthEnforced: true,
                              //The charge string cannot be longer than 4 characters hence e.g. - 43.6,2.25,20.6,20,20.0,2.22 etc.
                              maxLength: 4,
                              keyboardType: TextInputType.number,
                              controller: priceController,
                              decoration: InputDecoration(
                                hintText: 'Amount',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.toWidth,
                                    vertical: 8.toHeight),
                              ),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: buildDialogActionButton(
                          0,
                          () {
                            //Show error when entered charge value is invalid and further execution is halted.
                            if (priceController.text == '' ||
                                double.tryParse(priceController.text) == null) {
                              Fluttertoast.showToast(
                                  msg: 'Enter valid charge value!');
                              return;
                            }
                            Navigator.pop(
                                context,
                                AdditionalChargesDetails(
                                    chargeName: widget.dialogActionType == 0
                                        ? widget.availableChargesOptions[
                                            dropdownValue]
                                        : widget.toBeEditedChargeName,
                                    value: (double.parse(priceController.text) *
                                            100)
                                        .toInt()));
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20.toWidth,
                      ),
                      Expanded(
                          child: buildDialogActionButton(1, () {
                        Navigator.pop(context);
                      })),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get fineSeparator {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.toHeight),
      child: Container(
        height: 0.3.toHeight,
        color: AppColors.offGreyish,
      ),
    );
  }

  Widget get buildDropdownMenu {
    return DropdownButton(
      underline: SizedBox.shrink(),
      isDense: true,
      isExpanded: true,
      value: dropdownValue,
      items: List.generate(
        widget.availableChargesOptions.length,
        (index) => DropdownMenuItem(
          value: index,
          child: FittedBox(
            child: Text(
              AdditionChargesMetaDataGenerator.friendlyChargeNameFromKeyValue(
                  widget.availableChargesOptions[index]),
            ),
          ),
        ),
      ),
      onChanged: (v) => setState(() {
        dropdownValue = v;
      }),
    );
  }

  Widget get editChargeNameLabel {
    return Text(
      AdditionChargesMetaDataGenerator.friendlyChargeNameFromKeyValue(
              widget.toBeEditedChargeName) ??
          'Unknown Charge',
      style: TextStyle(
        color: AppColors.greyishText,
      ),
    );
  }

  Widget buildDialogActionButton(int type, Function onPressed) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.toHeight, top: 20.toHeight),
      child: RaisedButton(
        onPressed: onPressed,
        padding:
            EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 10.toWidth),
        color: type == 0 ? AppColors.lightBlue : Colors.red,
        child: Text(
          type == 0 ? 'Confirm' : 'Cancel',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
