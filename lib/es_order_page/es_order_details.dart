import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/es_order_page/es_order_add_item.dart';
import 'package:foore/es_order_page/widgets/order_item_tile.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:url_launcher/url_launcher.dart';

class EsOrderDetails extends StatefulWidget {
  static const routeName = '/order_details';

  final EsOrder esOrder;
  EsOrderDetails(this.esOrder);

  @override
  _EsOrderDetailsState createState() => _EsOrderDetailsState();
}

class _EsOrderDetailsState extends State<EsOrderDetails> {
  List<EsOrderItem> totalItems;
  double totalAmount;

  @override
  void initState() {
    totalItems = widget.esOrder?.orderItems ?? [];
    totalAmount = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    totalAmount = 0;
    totalItems.forEach((item) {
      totalAmount =
          totalAmount + (double.tryParse(item?.itemTotal?.substring(1)) ?? 0);
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'Order #' + widget.esOrder.orderShortNumber,
          style: Theme.of(context)
              .textTheme
              .subtitle1
              .copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (widget.esOrder?.customerPhones?.length != null &&
              widget.esOrder.customerPhones.length > 0) ...[
            IconButton(
              icon: Image.asset('assets/call.png'),
              onPressed: () {
                // TODO : which phone number to choose here.
                launch('tel:${widget.esOrder.customerPhones[0]}');
              },
            ),
            IconButton(
              icon: Image.asset('assets/whatsapp.png'),
              onPressed: () {
                if (Platform.isIOS) {
                  launch(
                      "whatsapp://wa.me/${widget.esOrder.customerPhones[0]}/?text=${Uri.parse('Message from eSamudaay.')}");
                } else {
                  launch(
                      "whatsapp://send?phone=${widget.esOrder.customerPhones[0]}&text=${Uri.parse('Message from eSamudaay.')}");
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
                      itemCount: totalItems?.length ?? 0,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => OrderItemTile(
                        totalItems[index],
                        (updatedItem) {
                          widget.esOrder.orderItems[index] = updatedItem;
                          setState(() {});
                        },
                        () {
                          setState(() {
                            totalItems.removeAt(index);
                          });
                        },
                      ),
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
                              totalItems = [...totalItems, ...value];
                              setState(() {});
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
              // SizedBox(height: 30.toHeight),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     vertical: 20.toHeight,
              //     horizontal: 15.toWidth,
              //   ),
              //   decoration: BoxDecoration(
              //     border: Border.all(
              //       color: Colors.grey[300],
              //     ),
              //   ),
              // ),
              SizedBox(height: 30.toHeight),
              if (widget.esOrder.customerNote != null) ...[
                Container(
                  child: Column(
                    children: [
                      Text(widget.esOrder.customerNote),
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
                    totalItems.length.toString() +
                        '  Item' +
                        (totalItems.length > 1 ? 's' : ''),
                  ),
                  Text('\u{20B9} $totalAmount')
                ],
              ),
              SizedBox(height: 30.toHeight),
              Align(
                alignment: Alignment.center,
                child: FoSubmitButton(
                  text: 'Accept Order',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
