import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:sprintf/sprintf.dart';

import 'confirm_dialogue.dart';

class OrderItemTile extends StatefulWidget {
  final EsOrderItem orderItem;
  final Function(int quantity, double unitPrice) onChanged;
  final Function() onDelete;
  final bool canBeUpdated;
  OrderItemTile(
    this.orderItem,
    this.onChanged,
    this.onDelete, {
    @required this.canBeUpdated,
  });
  @override
  _OrderItemTileState createState() => _OrderItemTileState();
}

class _OrderItemTileState extends State<OrderItemTile> {
  TextEditingController quantityController;
  TextEditingController priceController;
  @override
  void initState() {
    quantityController = new TextEditingController(
      text: (widget.orderItem?.itemQuantity ?? 1).toString(),
    );

    priceController = new TextEditingController(
      text: (widget.orderItem?.unitPrice ?? 0).toString(),
    );
    super.initState();
  }

  @override
  void dispose() {
    quantityController?.dispose();
    priceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.canBeUpdated,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Text(
              widget.orderItem.productName +
                  (widget.orderItem.variationOption != null
                      ? ("(${widget.orderItem.variationOption})")
                      : ''),
            ),
          ),
          Text('  x  '),
          Container(
            width: 20.toWidth,
            child: TextFormField(
              textAlign: TextAlign.center,
              controller: quantityController,
              keyboardType: TextInputType.number,
              onChanged: (v) {
                int quantity = int.tryParse(v ?? 1) ?? 1;
                widget.onChanged(
                  quantity,
                  widget.orderItem.unitPrice,
                );
              },
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Text('\u{20B9}'),
          Container(
            width: 70.toWidth,
            child: TextFormField(
              textAlign: TextAlign.center,
              controller: priceController,
              keyboardType: TextInputType.number,
              onChanged: (v) {
                double price = double.tryParse(v ?? 0) ?? 0;
                widget.onChanged(widget.orderItem.itemQuantity, price);
              },
            ),
          ),
          SizedBox(width: 6.toWidth),
          widget.canBeUpdated
              ? InkWell(
                  child: Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddOrDeleteItemDialogue(
                        message: sprintf(
                            AppTranslations.of(context).text(
                                'orders_page_sure_remove_item_from_the_order'),
                            [widget.orderItem.productName]),
                        onConfirm: widget.onDelete,
                      ),
                    );
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
