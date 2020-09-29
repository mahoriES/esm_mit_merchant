import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/services/sizeconfig.dart';

class OrderItemTile extends StatefulWidget {
  final EsOrderItem orderItem;
  final Function(EsOrderItem) onChanged;
  final Function() onDelete;
  OrderItemTile(
    this.orderItem,
    this.onChanged,
    this.onDelete,
  );
  @override
  _OrderItemTileState createState() => _OrderItemTileState();
}

class _OrderItemTileState extends State<OrderItemTile> {
  TextEditingController quantityController;
  TextEditingController priceController;
  @override
  void initState() {
    quantityController = new TextEditingController(
      text: widget.orderItem.itemQuantity.toString(),
    );

    priceController = new TextEditingController(
      text: widget?.orderItem?.itemTotal?.substring(1),
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
    return Row(
      children: <Widget>[
        Text(widget.orderItem.productName),
        widget.orderItem.variationOption != null
            ? Text("(" + widget.orderItem.variationOption + ")")
            : Container(),
        Text("  x   "),
        Container(
          width: 20.toWidth,
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: quantityController,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              int quantity = int.tryParse(v);
              widget.orderItem.itemQuantity = quantity ?? 0;
              widget.onChanged(widget.orderItem);
            },
          ),
        ),
        Flexible(child: Container()),
        Text(widget?.orderItem?.itemTotal?.substring(0, 1) ?? ''),
        Container(
          width: 70.toWidth,
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: priceController,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              int quantity = int.tryParse(v);
              widget.orderItem.itemTotal = (quantity ?? 0).toString();
              widget.onChanged(widget.orderItem);
            },
          ),
        ),
        SizedBox(width: 6.toWidth),
        IconButton(
          icon: Icon(Icons.cancel),
          onPressed: widget.onDelete,
        ),
      ],
    );
  }
}
