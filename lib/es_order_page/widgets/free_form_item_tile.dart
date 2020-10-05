import 'package:flutter/material.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/es_order_page/widgets/confirm_dialogue.dart';
import 'package:foore/services/sizeconfig.dart';

class FreeFormItemTile extends StatefulWidget {
  final FreeFormItems item;
  final Function() onReject;
  final Function() onConfirm;
  FreeFormItemTile({
    @required this.item,
    @required this.onReject,
    @required this.onConfirm,
  });

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
          color: widget.item.productStatus == FreeFormItemStatus.added
              ? Theme.of(context).primaryColor
              : Colors.grey,
          icon: Icon(Icons.check_circle),
          onPressed: () {
            if (widget.item.productStatus != FreeFormItemStatus.added) {
              showDialog(
                context: context,
                builder: (context) => AddOrDeleteItemDialogue(
                  message:
                      'Are you sure you want to add ${widget.item.skuName} to the order?',
                  onConfirm: widget.onConfirm,
                ),
              );
            }
          },
        ),
        IconButton(
          color: widget.item.productStatus == FreeFormItemStatus.notAdded
              ? Colors.red
              : Colors.grey,
          icon: Icon(Icons.cancel),
          onPressed: () {
            if (widget.item.productStatus != FreeFormItemStatus.notAdded) {
              showDialog(
                context: context,
                builder: (context) => AddOrDeleteItemDialogue(
                  message:
                      'Are you sure you want to remove ${widget.item.skuName} from the order?',
                  onConfirm: widget.onReject,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
