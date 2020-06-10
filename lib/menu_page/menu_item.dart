import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  final String name;
  final Function onTap;
  final String description;
  final String price;
  final String category;
  const MenuItemWidget(
      {this.name, this.onTap, this.description, this.price, this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20, left: 20,),
      child: GestureDetector(
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
                        child: Image.network('https://picsum.photos/200'),
                      ),
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            color: Colors.white70,
                            child: Text(
                              '+4',
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        color: Colors.black87,
                                      ),
                            ),
                          ),
                        ),
                      ),
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
                      'Apple',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: ListTileTheme.of(context).textColor,
                          ),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    Container(
                      child: Text(
                          "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', ",
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
                        Text('₹ 10.00',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                  // fontWeight: FontWeight.w600
                                )),
                        Flexible(
                          child: Container(),
                        ),
                        Text('+2 variations',
                            style: Theme.of(context).textTheme.caption),
                      ],
                    )
                  ],
                ),
              ),
            ),
            PopupMenuButton(
              onSelected: (result) {},
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: '',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: '',
                  child: Text('Activate'),
                ),
                const PopupMenuItem(
                  value: '',
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
