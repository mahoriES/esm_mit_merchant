import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foore/data/constants/string_constants.dart';
import 'package:foore/data/model/es_order_details.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/es_order_page/es_order_add_item.dart';
import 'package:foore/es_order_page/widgets/free_form_item_tile.dart';
import 'package:foore/es_order_page/widgets/order_item_tile.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/widgets/response_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_translations.dart';
import 'widgets/image_view.dart';
import 'widgets/order_details_charges_component.dart';

class EsOrderDetailsParam {
  EsOrderDetailsResponse esOrderDetailsResponse;
  Function(BuildContext) acceptOrder;
  //This is a single function which would work universally for order items and charge updation
  Function(BuildContext, UpdateOrderPayload) updateOrder;
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

  ///The [chargesUpdated] is static variable of the class [EsOrderDetails] and
  ///is assigned to a [ValueNotifier] of the type boolean. This flag variable, is set
  ///whenever the additional charges are added/updated by the user, and this value is used
  ///to show the button title for the CTA button, which changes to Update Order when the above
  ///mentioned scenario occurs.
  static var chargesUpdated = ValueNotifier(false);

  EsOrderDetails(this.params);

  @override
  _EsOrderDetailsState createState() => _EsOrderDetailsState();
}

class _EsOrderDetailsState extends State<EsOrderDetails> {
  EsOrderDetailsResponse details;
  bool isOrderUpdated;
  bool isOrderStatusCreated;

  bool get isCatalogueItemsNotAvailable =>
      details.orderItems
          .where((item) => item.itemStatus != CatalogueItemStatus.notPresent)
          .length ==
      0;

  @override
  void initState() {
    details = widget.params.esOrderDetailsResponse;
    isOrderUpdated = false;
    isOrderStatusCreated = details.orderStatus == 'CREATED';
    super.initState();
  }

  //This function works for these cases - i) When only order charges are updated  ii) When only order items are updated
  //iii) When both are updated
  _updateOrder() {
    widget.params.updateOrder(
        context,
        UpdateOrderPayload(
          additionalChargesUpdatedList: EsOrderDetails.chargesUpdated.value
              ? details.additionalChargesDetails
              : null,
          orderItems: List.generate(
            details.orderItems.length,
            (index) => UpdateOrderItems(
              productStatus: details.orderItems[index].itemStatus ==
                      CatalogueItemStatus.notPresent
                  ? details.orderItems[index].itemStatus
                  : null,
              skuId: int.tryParse(details.orderItems[index].skuId),
              quantity: details.orderItems[index].itemQuantity,
              unitPriceInRupee: details.orderItems[index].unitPrice,
            ),
          ),
          freeFormItems: details.freeFormItems,
        ));
  }

  Future<bool> _addItemsFromCatalogue() async {
    var value = await Navigator.of(context).pushNamed(EsOrderAddItem.routeName);
    if (value != null && value is List<EsOrderItem>) {
      isOrderUpdated = true;
      details.orderItems = [...details.orderItems, ...value];
      setState(() {});
      return value.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    bool allItemsUpdated = true;
    for (int i = 0; i < details.freeFormItems?.length; i++) {
      if (details.freeFormItems[i].productStatus ==
          FreeFormItemStatus.isAvailable) {
        allItemsUpdated = false;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          AppTranslations.of(context).text('orders_page_order') +
              ' #' +
              details.orderShortNumber,
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (details?.customerPhones?.length != null &&
              details.customerPhones.length > 0) ...[
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                child: Icon(
                  Icons.call_rounded,
                  size: 25.toHeight,
                  color: Colors.lightBlue,
                ),
                onTap: () => launch(
                  StringConstants.callUrlLauncher(
                    details.customerPhones[0],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.toWidth),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                child: Image.asset(
                  'assets/whatsapp.png',
                  width: 25.toWidth,
                  // fit: BoxFit.fill,
                ),
                onTap: () => launch(
                  Platform.isIOS
                      ? StringConstants.whatsAppIosLauncher(
                          details.customerPhones[0],
                          StringConstants.whatsAppMessage(
                              details.orderShortNumber, details.businessName),
                        )
                      : StringConstants.whatsAppAndroidLauncher(
                          details.customerPhones[0],
                          StringConstants.whatsAppMessage(
                              details.orderShortNumber, details.businessName),
                        ),
                ),
              ),
            ),
            SizedBox(width: 12.toWidth),
          ],
        ],
      ),
      body: IgnorePointer(
        ignoring: !isOrderStatusCreated,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.toWidth),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details.freeFormItems != null &&
                    details.freeFormItems.length > 0) ...[
                  SizedBox(height: 20.toHeight),
                  Text(
                    AppTranslations.of(context)
                        .text("orders_page_customer_item_list"),
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          fontSize: 15.toFont,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 5.toHeight),
                  Text(
                    AppTranslations.of(context)
                        .text("orders_page_customer_item_heading"),
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontSize: 12.toFont),
                  ),
                  SizedBox(height: 8.toHeight),
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: details.freeFormItems.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 8.toHeight),
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
                              message: AppTranslations.of(context)
                                  .text("orders_page_no_items_added_error"),
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
                ],
                Divider(
                  color: Colors.grey[400],
                  height: 20.toHeight,
                ),
                Text(
                  AppTranslations.of(context)
                      .text("orders_page_catalogue_items"),
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: 15.toFont,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8.toHeight),
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: details.orderItems?.length ?? 0,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: 8.toHeight),
                  itemBuilder: (context, index) {
                    if (details.orderItems[index].itemStatus ==
                        CatalogueItemStatus.notPresent)
                      return SizedBox.shrink();
                    return OrderItemTile(
                      details.orderItems[index],
                      (updatedQuantity, updatedUnitPrice) {
                        details.orderItems[index].itemQuantity =
                            updatedQuantity;
                        details.orderItems[index].unitPrice = updatedUnitPrice;
                        isOrderUpdated = true;
                        setState(() {});
                      },
                      () {
                        isOrderUpdated = true;
                        if (details.orderItems[index].itemStatus ==
                            CatalogueItemStatus.createdByMerchant) {
                          details.orderItems.removeAt(index);
                        } else {
                          details.orderItems[index].itemStatus =
                              CatalogueItemStatus.notPresent;
                        }
                        setState(() {});
                      },
                    );
                  },
                ),
                SizedBox(height: 15.toHeight),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 5.toWidth),
                        Text(
                          AppTranslations.of(context)
                              .text("orders_page_add_item"),
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                    onTap: () => _addItemsFromCatalogue(),
                  ),
                ),
                if (details.customerNote != null ||
                    (details.customerNoteImages != null &&
                        details.customerNoteImages.isNotEmpty)) ...[
                  Divider(
                    color: Colors.grey[400],
                    height: 20.toHeight,
                  ),
                ],
                if (details.customerNote != null) ...[
                  SizedBox(height: 10.toHeight),
                  Container(
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: AppTranslations.of(context)
                                .text("orders_page_note"),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: details.customerNote,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.toHeight)
                      ],
                    ),
                  ),
                ],
                if (details.customerNoteImages != null &&
                    details.customerNoteImages.isNotEmpty) ...[
                  SizedBox(height: 10.toHeight),
                  Wrap(
                    spacing: 10.toWidth,
                    runSpacing: 10.toHeight,
                    children: List.generate(
                      details.customerNoteImages.length,
                      (index) => InkWell(
                        onTap: () => showGeneralDialog(
                          barrierDismissible: false,
                          context: context,
                          pageBuilder: (context, _, __) =>
                              EsOrderDetailsImageView(
                            details.customerNoteImages[index] is String
                                ? details.customerNoteImages[index]
                                : (details
                                        .customerNoteImages[index]?.photoUrl ??
                                    ''),
                          ),
                        ),
                        child: Container(
                          width: (SizeConfig().screenWidth / 3) - 20.toWidth,
                          height: (SizeConfig().screenWidth / 3) - 20.toWidth,
                          color: Colors.grey[300],
                          child: CachedNetworkImage(
                            height: double.infinity,
                            width: double.infinity,
                            imageUrl:
                                details.customerNoteImages[index] is String
                                    ? details.customerNoteImages[index]
                                    : (details.customerNoteImages[index]
                                            ?.photoUrl ??
                                        ''),
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, _) => Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Divider(
                  color: Colors.grey[400],
                  height: 30.toHeight,
                ),
                EsOrderDetailsChargesComponent(details),
                SizedBox(height: 30.toHeight),
                !isOrderStatusCreated
                    ? Container()
                    : ValueListenableBuilder(
                        valueListenable: EsOrderDetails.chargesUpdated,
                        builder: (context, value, _) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: RaisedButton(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.toHeight),
                                  child: Text(
                                    AppTranslations.of(context)
                                        .text("orders_page_reject_order"),
                                  ),
                                  onPressed: () =>
                                      widget.params.cancelOrder(context),
                                  color: Theme.of(context).errorColor,
                                ),
                              ),
                              SizedBox(width: 20.toWidth),
                              Expanded(
                                flex: 1,
                                child: isCatalogueItemsNotAvailable
                                    ? RaisedButton(
                                        child: Text(AppTranslations.of(context)
                                            .text("orders_page_update_order")),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.toHeight),
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              ResponseDialogue(
                                            '',
                                            message:
                                                'Please add at least 1 item in the order',
                                          ),
                                        ),
                                        color: Colors.grey[400],
                                      )
                                    : (details.freeFormItems != null &&
                                            details.freeFormItems.length > 0)
                                        ? allItemsUpdated
                                            ? RaisedButton(
                                                child: Text(AppTranslations.of(
                                                        context)
                                                    .text(
                                                        "orders_page_update_order")),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.toHeight),
                                                onPressed: _updateOrder,
                                              )
                                            : RaisedButton(
                                                child: Text(AppTranslations.of(
                                                        context)
                                                    .text(
                                                        "orders_page_update_order")),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.toHeight),
                                                onPressed: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      ResponseDialogue(
                                                    '',
                                                    message: AppTranslations.of(
                                                            context)
                                                        .text(
                                                            "orders_page_customer_items_due_error"),
                                                  ),
                                                ),
                                                color: Colors.grey[400],
                                              )

                                        ///The [ValueNotifier] flag is used here to update the button title
                                        : (isOrderUpdated || value)
                                            ? RaisedButton(
                                                child: Text(AppTranslations.of(
                                                        context)
                                                    .text(
                                                        "orders_page_update_order")),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.toHeight),
                                                onPressed: _updateOrder,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              )
                                            : RaisedButton(
                                                child: Text(AppTranslations.of(
                                                        context)
                                                    .text(
                                                        "orders_page_accept_order")),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.toHeight),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                onPressed: () {
                                                  debugPrint('Accept tapped');
                                                  debugPrint(details
                                                      .additionalChargesDetails
                                                      .toString());
                                                  widget.params
                                                      .acceptOrder(context);
                                                },
                                              ),
                              ),
                            ],
                          );
                        }),
                SizedBox(height: 30.toHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
