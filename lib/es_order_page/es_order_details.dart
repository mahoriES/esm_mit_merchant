import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/es_order_page/es_order_add_item.dart';
import 'package:foore/es_order_page/widgets/free_form_item_tile.dart';
import 'package:foore/es_order_page/widgets/order_item_tile.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:url_launcher/url_launcher.dart';

class EsOrderDetailsParam {
  EsOrderDetailsResponse esOrderDetailsResponse;
  Function(BuildContext) acceptOrder;
  Function(BuildContext, UpdateOrderItemsPayload) updateOrder;

  EsOrderDetailsParam({
    @required this.esOrderDetailsResponse,
    @required this.acceptOrder,
    @required this.updateOrder,
  });
}

class EsOrderDetails extends StatefulWidget {
  static const routeName = '/order_details';

  final EsOrderDetailsParam params;
  EsOrderDetails(this.params);

  @override
  _EsOrderDetailsState createState() => _EsOrderDetailsState();
}

class _EsOrderDetailsState extends State<EsOrderDetails> {
  EsOrderDetailsResponse details;
  double totalAmount;
  bool isUpdated;
  List<bool> isFreeFormItemUpdated;
  bool allItemsUpdates;
  Map<int, String> itemStatus;

  @override
  void initState() {
    details = widget.params.esOrderDetailsResponse;
    totalAmount = 0;
    isUpdated = false;
    itemStatus = {};
    for (int i = 0; i < details.orderItems?.length ?? 0; i++) {
      itemStatus[i] = CatalogueItemStatus.addedToOrder;
    }

    isFreeFormItemUpdated = List.generate(
      details.freeFormItems?.length ?? 0,
      (i) => false,
    );
    super.initState();
  }

  _updateOrder() {
    widget.params.updateOrder(
      context,
      UpdateOrderItemsPayload(
        orderItems: List.generate(
          details.orderItems.length,
          (index) => UpdateOrderItems(
            productStatus: itemStatus[index] == CatalogueItemStatus.notPresent
                ? itemStatus[index]
                : null,
            skuId: int.tryParse(details.orderItems[index].skuId),
            quantity: details.orderItems[index].itemQuantity,
            unitPrice: details.orderItems[index].unitPrice,
          ),
        ),
        freeFormItems: details.freeFormItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    totalAmount = 0;
    details.orderItems.forEach((item) {
      totalAmount = totalAmount +
          (item?.unitPrice ?? 0) * (item.itemQuantity?.toDouble() ?? 0);
    });
    allItemsUpdates = true;
    for (int i = 0; i < isFreeFormItemUpdated.length; i++) {
      if (!isFreeFormItemUpdated[i]) {
        allItemsUpdates = false;
      } else if (details.freeFormItems[i].productStatus ==
          FreeFormItemStatus.added) {
        totalAmount = totalAmount + (details.freeFormItems[i].price ?? 0);
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'Order #' + details.orderShortNumber,
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (details?.customerPhones?.length != null &&
              details.customerPhones.length > 0) ...[
            IconButton(
              icon: Image.asset('assets/call.png'),
              onPressed: () {
                // TODO : which phone number to choose here.
                launch('tel:${details.customerPhones[0]}');
              },
            ),
            IconButton(
              icon: Image.asset('assets/whatsapp.png'),
              onPressed: () {
                if (Platform.isIOS) {
                  launch(
                      "whatsapp://wa.me/${details.customerPhones[0]}/?text=${Uri.parse('Message from eSamudaay.')}");
                } else {
                  launch(
                      "whatsapp://send?phone=${details.customerPhones[0]}&text=${Uri.parse('Message from eSamudaay.')}");
                }
              },
            ),
          ],
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.toWidth),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.toHeight),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 20.toHeight,
                  horizontal: 15.toWidth,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300],
                  ),
                ),
                child: Column(
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: details.orderItems?.length ?? 0,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (itemStatus[index] == CatalogueItemStatus.notPresent)
                          return Container();
                        return OrderItemTile(
                          details.orderItems[index],
                          (updatedQuantity, updatedUnitPrice) {
                            details.orderItems[index].itemQuantity =
                                updatedQuantity;
                            details.orderItems[index].unitPrice =
                                updatedUnitPrice;
                            isUpdated = true;
                            setState(() {});
                          },
                          () {
                            isUpdated = true;
                            if (itemStatus[index] ==
                                CatalogueItemStatus.createdInCatalogue) {
                              details.orderItems.removeAt(index);
                            } else
                              itemStatus[index] =
                                  CatalogueItemStatus.notPresent;
                            setState(() {});
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20.toHeight),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.all(8.toFont),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12.toFont),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            Text(
                              'Add Item',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(EsOrderAddItem.routeName)
                            .then(
                          (value) {
                            if (value != null && value is List<EsOrderItem>) {
                              isUpdated = true;
                              int length = details.orderItems.length;
                              for (int i = 0; i < value.length; i++) {
                                details.orderItems.add(value[i]);
                                itemStatus[i + length] =
                                    CatalogueItemStatus.createdInCatalogue;
                              }

                              setState(() {});
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
              if (details.freeFormItems != null &&
                  details.freeFormItems.length > 0) ...[
                SizedBox(height: 20.toHeight),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.toHeight,
                    horizontal: 15.toWidth,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300],
                    ),
                  ),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: details.freeFormItems.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => FreeFormItemTile(
                      details.freeFormItems[index],
                      details.orderStatus == 'CREATED'
                          ? isFreeFormItemUpdated[index]
                          : true,
                      (updatedItem) {
                        isFreeFormItemUpdated[index] = true;
                        details.freeFormItems[index] = updatedItem;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
              if (details.customerNote != null) ...[
                SizedBox(height: 30.toHeight),
                Container(
                  child: Column(
                    children: [
                      Text(details.customerNote),
                      SizedBox(height: 10.toHeight)
                    ],
                  ),
                ),
              ],
              SizedBox(height: 30.toHeight),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    details.orderItems.length.toString() +
                        '  Item' +
                        (details.orderItems.length > 1 ? 's' : ''),
                  ),
                  Text('\u{20B9} $totalAmount')
                ],
              ),
              if (details.customerNoteImages != null &&
                  details.customerNoteImages.isNotEmpty) ...[
                SizedBox(height: 30.toHeight),
                Wrap(
                  spacing: 10.toWidth,
                  runSpacing: 10.toHeight,
                  children: List.generate(
                    details.customerNoteImages.length,
                    (index) => Container(
                      width: (SizeConfig().screenWidth / 3) - 20.toWidth,
                      height: (SizeConfig().screenWidth / 3) - 20.toWidth,
                      color: Colors.grey[300],
                      child: Image.network(
                        details.customerNoteImages[index],
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 30.toHeight),
              Align(
                alignment: Alignment.center,
                child: details.orderItems.length == 0
                    ? Container()
                    : (details.freeFormItems != null &&
                            details.freeFormItems.length > 0)
                        ? allItemsUpdates
                            ? FoSubmitButton(
                                text: 'Update Order',
                                onPressed: _updateOrder,
                              )
                            : Container()
                        : isUpdated
                            ? FoSubmitButton(
                                text: 'Update Order',
                                onPressed: _updateOrder,
                              )
                            : FoSubmitButton(
                                text: 'Accept Order',
                                onPressed: () =>
                                    widget.params.acceptOrder(context),
                              ),
              ),
              SizedBox(height: 30.toHeight),
            ],
          ),
        ),
      ),
    );
  }
}
