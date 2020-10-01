import 'package:flutter/material.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/widgets/response_dialog.dart';

class FreeFormItemTile extends StatefulWidget {
  final FreeFormItems item;
  final bool isUpdated;
  final Function(FreeFormItems) onUpdate;
  FreeFormItemTile(
    this.item,
    this.isUpdated,
    this.onUpdate,
  );

  @override
  _FreeFormItemTileState createState() => _FreeFormItemTileState();
}

class _FreeFormItemTileState extends State<FreeFormItemTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.item.skuName + '  x  ' + widget.item.quantity.toString()),
        SizedBox(width: 10.toWidth),
        Flexible(
          child: Container(),
        ),
        SizedBox(width: 10.toWidth),
        IconButton(
          color: widget.isUpdated &&
                  widget.item.productStatus == FreeFormItemStatus.added
              ? Colors.green
              : Colors.grey,
          icon: Icon(Icons.check_circle),
          onPressed: () {
            widget.item.productStatus = FreeFormItemStatus.added;
            widget.onUpdate(widget.item);
            showDialog(
              context: context,
              builder: (context) => ResponseDialogue(
                "You have accepted this item.",
                message: "Don't forget to add item from products menu!! ",
              ),
            );
          },
        ),
        IconButton(
          color: widget.isUpdated &&
                  widget.item.productStatus == FreeFormItemStatus.notAdded
              ? Colors.red
              : Colors.grey,
          icon: Icon(Icons.cancel),
          onPressed: () {
            widget.item.productStatus = FreeFormItemStatus.notAdded;
            widget.onUpdate(widget.item);
          },
        ),
      ],
    );
  }
}
