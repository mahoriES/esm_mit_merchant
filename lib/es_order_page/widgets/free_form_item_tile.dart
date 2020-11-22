import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/es_order_page/widgets/confirm_dialogue.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:sprintf/sprintf.dart';

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
        InkWell(
          child: Icon(
            Icons.check_circle,
            color: widget.item.productStatus == FreeFormItemStatus.added
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onTap: () {
            if (widget.item.productStatus != FreeFormItemStatus.added) {
              showDialog(
                context: context,
                builder: (context) => AddOrDeleteItemDialogue(
                  message: sprintf(
                      AppTranslations.of(context).text(
                          'orders_page_sure_add_item_to_the_order'),
                      [widget.item.skuName]),
                  onConfirm: widget.onConfirm,
                ),
              );
            }
          },
        ),
        SizedBox(width: 15.toWidth),
        InkWell(
          child: Icon(
            Icons.cancel,
            color: widget.item.productStatus == FreeFormItemStatus.notAdded
                ? Colors.red
                : Colors.grey,
          ),
          onTap: () {
            if (widget.item.productStatus != FreeFormItemStatus.notAdded) {
              showDialog(
                context: context,
                builder: (context) => AddOrDeleteItemDialogue(
                  message: sprintf(
                      AppTranslations.of(context).text(
                          'orders_page_sure_remove_item_from_the_order'),
                      [widget.item.skuName]),
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
