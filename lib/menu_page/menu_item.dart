import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/model/es_product.dart';

class MenuItemWidget extends StatelessWidget {
  final EsProduct esProduct;
  final Function(EsProduct) onEdit;
  final Function(EsProduct) onTap;
  final Function(EsProduct) onDelete;
  // use these three values when navigating here from add_item in order flow.
  final bool isAddOrderItem;
  final Function() onAdd;
  final bool isItemAdded;
  //
  const MenuItemWidget({
    this.esProduct,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.isAddOrderItem = false,
    this.isItemAdded = false,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 20,
        left: 20,
      ),
      child: GestureDetector(
        onTap: () {
          if (!isAddOrderItem) this.onTap(this.esProduct);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              elevation: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                  height: 80,
                  width: 80,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        child: esProduct.dPhotoUrl != ''
                            ? Image.network(esProduct.dPhotoUrl)
                            : Container(),
                      ),
                      esProduct.dNumberOfMorePhotos > 0
                          ? Positioned(
                              left: 4,
                              bottom: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  color: Colors.white70,
                                  child: Text(
                                    '+${esProduct.dNumberOfMorePhotos}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                          color: Colors.black87,
                                        ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      esProduct.dProductName,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: ListTileTheme.of(context).textColor,
                          ),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Container(
                      child: Text(esProduct.dProductDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color:
                                    Theme.of(context).textTheme.caption.color,
                              )),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: esProduct.skus.length > 0
                              ? Text(
                                  esProduct.dPrice,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                        // fontWeight: FontWeight.w600
                                      ),
                                )
                              : Text(
                                  AppTranslations.of(context)
                                      .text('products_page_no_skus'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color: Theme.of(context).errorColor,
                                        // fontWeight: FontWeight.w600
                                      ),
                                ),
                        ),
                        Flexible(
                          child: Container(),
                        ),
                        esProduct.dNumberOfMoreVariations > 0
                            ? Text(
                                '+${esProduct.dNumberOfMoreVariations} ' +
                                    AppTranslations.of(context)
                                        .text('products_page_variations'),
                                style: Theme.of(context).textTheme.caption)
                            : Container(),
                      ],
                    )
                  ],
                ),
              ),
            ),
            isAddOrderItem
                ? IconButton(
                    color: esProduct.skus.length > 0
                        ? Colors.black
                        : Colors.grey[300],
                    icon: isItemAdded
                        ? Icon(Icons.check_circle)
                        : Icon(Icons.add_circle),
                    onPressed: esProduct.skus.length > 0 ? this.onAdd : null,
                  )
                : PopupMenuButton<int>(
                    onSelected: (result) {
                      if (result == 1) {
                        this.onEdit(this.esProduct);
                      }

                      // else if (result == 2) {
                      //   this.onDelete(this.esProduct);
                      // }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                      PopupMenuItem(
                        value: 1,
                        child: Text(AppTranslations.of(context)
                            .text('products_page_view')),
                      ),
                      // const PopupMenuItem(
                      //   value: '',
                      //   child: Text('Activate'),
                      // ),
                      // const PopupMenuItem(
                      //   value: 2,
                      //   child: Text('Delete'),
                      // ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
