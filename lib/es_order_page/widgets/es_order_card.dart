import 'package:flutter/material.dart';
import 'package:foore/data/model/es_orders.dart';
import 'package:foore/services/sizeconfig.dart';

class EsOrderCardParams {
  EsOrder esOrder;
  Function() goToDetails;

  EsOrderCardParams(this.esOrder, this.goToDetails);
}

class EsOrderCard extends StatelessWidget {
  final EsOrderCardParams params;
  EsOrderCard(this.params);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin:
          EdgeInsets.symmetric(horizontal: 20.toWidth, vertical: 10.toHeight),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 8.toWidth, vertical: 8.toHeight),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #' + params.esOrder.orderShortNumber,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          color: Theme.of(context).textTheme.caption.color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 5.toHeight),
                  Text(
                    params.esOrder.getCreatedTimeText(),
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(height: 5.toHeight),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "Order Total:",
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                              color: ListTileTheme.of(context).textColor,
                            ),
                      ),
                      SizedBox(
                        width: 4.toWidth,
                      ),
                      Text(
                        params.esOrder.dOrderTotal,
                        style: Theme.of(context).textTheme.subtitle2.copyWith(
                              color: ListTileTheme.of(context).textColor,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.toHeight),
                  Text(
                    params.esOrder.dDeliveryType,
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: ListTileTheme.of(context).textColor,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    params.esOrder.dIsStatusNew
                        ? Icon(
                            Icons.new_releases,
                            size: 16,
                            color: Colors.orange,
                          )
                        : params.esOrder.dIsStatusCancelled
                            ? Icon(
                                Icons.cancel,
                                size: 16,
                                color: Colors.red,
                              )
                            : params.esOrder.dIsStatusComplete
                                ? Icon(
                                    Icons.done_all,
                                    size: 16,
                                  )
                                : Icon(
                                    Icons.sync,
                                    size: 16,
                                  ),
                    SizedBox(
                      width: 4.toWidth,
                    ),
                    Text(
                      params.esOrder.dStatusString,
                      style: Theme.of(context).textTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 30.toHeight),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  iconSize: 30.toFont,
                  onPressed: () {
                    params.goToDetails();
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
