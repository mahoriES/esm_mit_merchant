import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/constants/string_constants.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/services/validation.dart';

class AdditionalChargeDialogue extends StatefulWidget {
  final Map<String, double> alreadySelectedCharges;
  AdditionalChargeDialogue({this.alreadySelectedCharges});
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
    return GestureDetector(
      onTap: () {
        focusNode?.unfocus();
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.toWidth,
              vertical: 20.toHeight,
            ),
            margin: EdgeInsets.symmetric(horizontal: 30.toWidth),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 4,
                      child: DropdownButton(
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
                      ),
                    ),
                    SizedBox(width: 12.toWidth),
                    Flexible(
                      flex: 3,
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          controller: priceController,
                          validator: ValidationService().validateString,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Amount',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.toWidth, vertical: 8.toHeight),
                          ),
                          focusNode: focusNode,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.toWidth),
                    Flexible(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            selectedCharges[StringConstants
                                    .additionalChargesStrings[dropdownValue]] =
                                double.tryParse(priceController.text) ?? 0;
                            setState(() {});
                            priceController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedCharges.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                      selectedCharges.keys.elementAt(index),
                    ),
                    subtitle: Text(
                      selectedCharges.values.elementAt(index).toString(),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCharges
                              .remove(selectedCharges.keys.elementAt(index));
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10.toHeight),
                Row(
                  children: [
                    FoSubmitButton(
                      text: 'Confirm',
                      onPressed: () {
                        Navigator.of(context).pop(selectedCharges);
                      },
                    ),
                    SizedBox(width: 12.toWidth),
                    FoSubmitButton(
                      text: 'Cancel',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
