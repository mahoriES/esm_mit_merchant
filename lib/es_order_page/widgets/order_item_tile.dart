import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/services/sizeconfig.dart';

class OrderItemTile extends StatefulWidget {
  final EsOrderItem orderItem;
  final Function(int quantity, double unitPrice) onChanged;
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
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Text(
            widget.orderItem.productName +
                (widget.orderItem.variationOption != null
                    ? ("(${widget.orderItem.variationOption})")
                    : ''),
          ),
        ),
        Text('  x  '),
        Expanded(
          flex: 2,
          child: Container(
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
        ),
        Flexible(
          flex: 4,
          child: Container(),
        ),
        Text('\u{20B9}'),
        Expanded(
          flex: 3,
          child: Container(
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
        ),
        SizedBox(width: 6.toWidth),
        Expanded(
          flex: 2,
          child: IconButton(
            color: Colors.red,
            icon: Icon(Icons.cancel),
            onPressed: widget.onDelete,
          ),
        ),
      ],
    );
  }
}
