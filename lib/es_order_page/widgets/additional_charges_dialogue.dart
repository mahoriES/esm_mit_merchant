import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/constants/string_constants.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/services/validation.dart';

class AdditionalChargeDialogue extends StatefulWidget {
  final Map<String, double> alreadySelectedCharges;
  final int dialogActionType;
  final String toBeEditedChargeName;

  AdditionalChargeDialogue({
    @required this.alreadySelectedCharges,
    @required this.dialogActionType,
    this.toBeEditedChargeName,
  });

  @override
  _AdditionalChargeDialogueState createState() =>
      _AdditionalChargeDialogueState();
}

class _AdditionalChargeDialogueState extends State<AdditionalChargeDialogue> {
  FocusNode focusNode = new FocusNode();
  int dropdownValue;
  Map<String, double> selectedCharges;
  TextEditingController priceController = new TextEditingController();
  GlobalKey<FormState> formKey = new GlobalKey();

  @override
  void initState() {
    dropdownValue = 0;
    selectedCharges = widget.alreadySelectedCharges ?? {};
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
        : 'Add ${widget.toBeEditedChargeName}';
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
                    style: TextStyle(color: AppColors.blackTextColor,fontSize: 20.toFont),
                  ),
                  fineSeparator,
                  Row(
                    children: [
                      Expanded(
                          flex: 60,
                          child: widget.dialogActionType == 0
                              ? buildDropdownMenu()
                              : editChargeNameLabel),
                      Expanded(flex: 10,child: SizedBox.shrink()),
                      Expanded(
                          flex: 30,
                          child: TextField(
                              maxLengthEnforced: true,
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              controller: priceController,
                              decoration: InputDecoration(
                                hintText: 'Amount',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.toWidth, vertical: 8.toHeight),
                              ),
                              textAlign: TextAlign.center)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: buildDialogActionButton(0, (){})),
                      SizedBox(width: 20.toWidth,),
                      Expanded(child: buildDialogActionButton(1, (){Navigator.pop(context);})),
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
    return Padding(padding: EdgeInsets.symmetric(vertical: 15.toHeight),
      child: Container(
        height: 0.3.toHeight,
        color: AppColors.offGreyish,
      ),
    );
  }

  Widget buildDropdownMenu() {
    return DropdownButton(
      isDense: true,
      isExpanded: true,
      value: dropdownValue,
      items: List.generate(
        StringConstants.additionalChargesStrings.length,
        (index) => DropdownMenuItem(
          value: index,
          child: FittedBox(
            child: Text(
              StringConstants.additionalChargesStrings[index],
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
      widget.toBeEditedChargeName??'Unknown Charge',
      style: TextStyle(
        color: AppColors.greyishText,
      ),
    );
  }

  Widget buildDialogActionButton(int type, Function onPressed) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.toHeight,top: 20.toHeight),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.toHeight,
              horizontal: 10.toWidth),
          decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.all(Radius.circular(20.toWidth)),
              border: Border.all(width: 2.0,
                  color: type == 0 ? AppColors.lightBlue : Colors.red)),
          child: Text(type == 0 ? 'Confirm' : 'Cancel', textAlign: TextAlign.center,style: TextStyle(
            color: type == 0 ? AppColors.lightBlue : Colors.red
          ),),
        ),
      ),
    );
  }
}
