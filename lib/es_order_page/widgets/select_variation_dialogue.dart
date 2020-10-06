import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/services/sizeconfig.dart';

class SelectVariationDialogue extends StatefulWidget {
  final EsProduct product;
  final Function(int) addItem;

  const SelectVariationDialogue(this.product, this.addItem);

  @override
  _SelectVariationDialogueState createState() =>
      _SelectVariationDialogueState();
}

class _SelectVariationDialogueState extends State<SelectVariationDialogue> {
  int selectedIndex;
  @override
  void initState() {
    selectedIndex = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.toWidth,
            vertical: 20.toHeight,
          ),
          margin: EdgeInsets.symmetric(horizontal: 50.toWidth),
          decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(20.toFont),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.product.skus != null
                    ? widget.product.skus.length
                    : 0,
                itemBuilder: (context, index) {
                  EsSku sku = widget.product.skus[index];
                  return ListTile(
                    title: (sku.variationValue != null) &&
                            sku.variationValue.isNotEmpty
                        ? Text(sku.dBasePrice + " (" + sku.variationValue + ")")
                        : Text(sku.dBasePrice),
                    // SizedBox(height: 4),
                    subtitle: Text(
                      sku.skuCode,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    trailing: IconButton(
                      icon: index == selectedIndex
                          ? Icon(Icons.check_circle)
                          : Icon(Icons.add_circle),
                      color: Colors.black,
                      onPressed: () {
                        if (selectedIndex == index)
                          selectedIndex = -1;
                        else
                          selectedIndex = index;
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 10.toHeight),
              FoSubmitButton(
                text: 'Select',
                onPressed: () {
                  widget.addItem(selectedIndex);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
