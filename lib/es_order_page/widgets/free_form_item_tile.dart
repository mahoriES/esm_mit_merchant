import 'package:flutter/material.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/services/sizeconfig.dart';

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
  TextEditingController priceController;
  @override
  void initState() {
    priceController = new TextEditingController(
      text: (widget.item?.price ?? 0).toString(),
    );
    super.initState();
  }

  @override
  void dispose() {
    priceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
              widget.item.skuName + '  x  ' + widget.item.quantity.toString()),
        ),
        SizedBox(width: 10.toWidth),
        Text('\u{20B9}'),
        Expanded(
          flex: 2,
          child: Container(
            width: 70.toWidth,
            child: TextFormField(
              textAlign: TextAlign.center,
              controller: priceController,
              keyboardType: TextInputType.number,
              onChanged: (v) {
                widget.item.price = double.tryParse(v ?? '0') ?? 0;
                widget.onUpdate(widget.item);
              },
            ),
          ),
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
        // PopupMenuButton(
        //   icon: Icon(
        //     Icons.cancel,
        //     color: widget.isUpdated &&
        //             !(widget.item.productStatus == FreeFormItemStatus.added)
        //         ? Colors.red
        //         : Colors.grey,
        //   ),
        //   onSelected: (v) async {
        //     if (v == 0) {
        //       widget.item.productStatus = FreeFormItemStatus.notAdded;
        //     }
        //     if (v == 1) {
        //       widget.item.productStatus = FreeFormItemStatus.notAdded;
        //     }
        //     widget.onUpdate(widget.item);
        //   },
        //   itemBuilder: (context) => <PopupMenuItem>[
        //     PopupMenuItem(
        //       value: 0,
        //       child: Text('Not in Stock'),
        //     ),
        //     PopupMenuItem(
        //       value: 1,
        //       child: Text('Permanantly Unavailable'),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
