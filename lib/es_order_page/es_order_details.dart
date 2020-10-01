import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/es_order_page/es_order_add_item.dart';
import 'package:foore/es_order_page/widgets/free_form_item_tile.dart';
import 'package:foore/es_order_page/widgets/order_item_tile.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/widgets/response_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class EsOrderDetailsParam {
  EsOrderDetailsResponse esOrderDetailsResponse;
  Function(BuildContext) acceptOrder;
  Function(BuildContext, UpdateOrderItemsPayload) updateOrder;
  Function(BuildContext) cancelOrder;

  EsOrderDetailsParam({
    @required this.esOrderDetailsResponse,
    @required this.acceptOrder,
    @required this.updateOrder,
    @required this.cancelOrder,
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
  int totalNumberOfItems;
  bool isUpdated;
  bool allItemsUpdated;
  Map<int, String> itemStatus;

  @override
  void initState() {
    details = widget.params.esOrderDetailsResponse;
    totalAmount = 0;
    totalNumberOfItems = 0;
    isUpdated = false;
    itemStatus = {};
    for (int i = 0; i < details.orderItems?.length ?? 0; i++) {
      itemStatus[i] = CatalogueItemStatus.addedToOrder;
    }

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

  Future<bool> _addItemsFromCatalogue() async {
    var value = await Navigator.of(context).pushNamed(EsOrderAddItem.routeName);
    if (value != null && value is List<EsOrderItem>) {
      isUpdated = true;
      int length = details.orderItems.length;
      for (int i = 0; i < value.length; i++) {
        details.orderItems.add(value[i]);
        itemStatus[i + length] = CatalogueItemStatus.createdInCatalogue;
      }
      setState(() {});
      return value.isNotEmpty;
    }
    return false;
  }

  void showImageInFullScreenMode(String imageUrl) {
    showGeneralDialog(
      barrierColor: null,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 150),
      context: context,
      pageBuilder: (context, _, __) => new Scaffold(
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                height: double.infinity,
                width: double.infinity,
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    totalAmount = 0;
    for (int i = 0; i < details.orderItems?.length; i++) {
      if (itemStatus[i] != CatalogueItemStatus.notPresent)
        totalAmount = totalAmount +
            (details.orderItems[i]?.unitPrice ?? 0) *
                (details.orderItems[i].itemQuantity?.toDouble() ?? 0);
    }

    double deliveryCharges = (details?.deliveryCharges ?? 0) / 100;
    double otherCharges = (details?.otherCharges ?? 0) / 100;

    allItemsUpdated = true;
    for (int i = 0; i < details.freeFormItems?.length; i++) {
      if (details.freeFormItems[i].productStatus ==
          FreeFormItemStatus.isAvailable) {
        allItemsUpdated = false;
        break;
      }
    }

    totalNumberOfItems = 0;
    for (int i = 0; i < details.orderItems?.length; i++) {
      if (itemStatus[i] != CatalogueItemStatus.notPresent)
        totalNumberOfItems =
            totalNumberOfItems + details.orderItems[i].itemQuantity;
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
      body: IgnorePointer(
        ignoring: details.orderStatus != 'CREATED',
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.toWidth),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        item: details.freeFormItems[index],
                        onConfirm: () async {
                          bool isItemAdded = await _addItemsFromCatalogue();
                          if (isItemAdded) {
                            details.freeFormItems[index].productStatus =
                                FreeFormItemStatus.added;
                            setState(() {});
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => ResponseDialogue(
                                '',
                                message: 'Add atleast 1 item to confirm this.',
                              ),
                            );
                          }
                        },
                        onReject: () {
                          details.freeFormItems[index].productStatus =
                              FreeFormItemStatus.notAdded;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
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
                          if (itemStatus[index] ==
                              CatalogueItemStatus.notPresent)
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
                              } else {
                                itemStatus[index] =
                                    CatalogueItemStatus.notPresent;
                              }
                              setState(() {});
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20.toHeight),
                      details.orderStatus != 'CREATED'
                          ? Container()
                          : InkWell(
                              child: Container(
                                padding: EdgeInsets.all(8.toFont),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius:
                                      BorderRadius.circular(12.toFont),
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
                              onTap: () => _addItemsFromCatalogue(),
                            )
                    ],
                  ),
                ),
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
                    Text('Delivery Charges'),
                    Text('\u{20B9} $deliveryCharges')
                  ],
                ),
                SizedBox(height: 10.toHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Additional Charges'),
                    Text('\u{20B9} $otherCharges')
                  ],
                ),
                SizedBox(height: 10.toHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalNumberOfItems.toString() +
                          '  Item' +
                          (totalNumberOfItems > 1 ? 's' : ''),
                    ),
                    Text(
                      '\u{20B9} ${totalAmount.toStringAsFixed(2)}',
                    )
                  ],
                ),
                // SizedBox(height: 10.toHeight),
                Divider(
                  color: Colors.grey[400],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount'),
                    Text(
                      '\u{20B9} ${(totalAmount + deliveryCharges + otherCharges).toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    )
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
                      (index) => InkWell(
                        onTap: () => showImageInFullScreenMode(
                            details.customerNoteImages[index]),
                        child: Container(
                          width: (SizeConfig().screenWidth / 3) - 20.toWidth,
                          height: (SizeConfig().screenWidth / 3) - 20.toWidth,
                          color: Colors.grey[300],
                          child: CachedNetworkImage(
                            height: double.infinity,
                            width: double.infinity,
                            imageUrl: details.customerNoteImages[index],
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 30.toHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FoSubmitButton(
                      text: 'Reject Order',
                      onPressed: () => widget.params.cancelOrder(context),
                      color: Colors.red,
                    ),
                    details.orderStatus != 'CREATED'
                        ? Container()
                        : details.orderItems.length == 0
                            ? FoSubmitButton(
                                text: 'Update Order',
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => ResponseDialogue(
                                    '',
                                    message:
                                        'Please add atleast 1 item in the order',
                                  ),
                                ),
                                color: Colors.grey[400],
                              )
                            : (details.freeFormItems != null &&
                                    details.freeFormItems.length > 0)
                                ? allItemsUpdated
                                    ? FoSubmitButton(
                                        text: 'Update Order',
                                        onPressed: _updateOrder,
                                      )
                                    : FoSubmitButton(
                                        text: 'Update Order',
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              ResponseDialogue(
                                            '',
                                            message:
                                                'Please Accept/Decline the list items first',
                                          ),
                                        ),
                                        color: Colors.grey[400],
                                      )
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
                  ],
                ),
                SizedBox(height: 30.toHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
