import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_edit_product.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:provider/provider.dart';

class EsProductDetailPage extends StatefulWidget {
  static const routeName = '/view-menu-item';
  final EsProduct currentProduct;

  EsProductDetailPage(this.currentProduct);

  @override
  EsProductDetailPageState createState() => EsProductDetailPageState();
}

class EsProductDetailPageState extends State<EsProductDetailPage>
    with AfterLayoutMixin<EsProductDetailPage> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  _showFailedAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit failed'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    esEditProductBloc.setCurrentProduct(widget.currentProduct);
    esEditProductBloc.esEditProductStateObservable.listen((event) {
      if (event.isSubmitFailed) {
        this._showFailedAlertDialog();
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final esEditProductBloc = Provider.of<EsEditProductBloc>(context);
    submit() {
      if (this._formKey.currentState.validate()) {
        esEditProductBloc.addProduct((EsProduct product) {
          Navigator.of(context).pop(product);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentProduct.dProductName,
        ),
      ),
      body: StreamBuilder<EsEditProductState>(
          stream: esEditProductBloc.esEditProductStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return Form(
              key: _formKey,
              onWillPop: _onWillPop,
              child: Scrollbar(
                child: ListView(
                  children: <Widget>[
                    Visibility(
                      visible: widget.currentProduct.images != null
                          ? widget.currentProduct.images.length > 0
                          : false,
                      child: Container(
                        height: 130,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.currentProduct.images != null
                                ? widget.currentProduct.images.length
                                : 0,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.only(right: 12),
                                child: Material(
                                  elevation: 1.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      child: Container(
                                        child: Image.network(widget
                                            .currentProduct
                                            .images[index]
                                            .photoUrl),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Active",
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Switch(
                          value: widget.currentProduct.isActive,
                          onChanged: (value) {}),
                    ),
                    ListTile(
                      title: Text(
                        "Stock",
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Switch(
                          value: widget.currentProduct.inStock,
                          onChanged: (value) {}),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        left: 20,
                        right: 20,
                        bottom: 4,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Short description',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.currentProduct.dProductDescription,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(
                          //     Icons.edit,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                        bottom: 4,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Long description',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.currentProduct.dProductLongDescription,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(
                          //     Icons.edit,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                        bottom: 4,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Display line 1',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.currentProduct.dLine1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(
                          //     Icons.edit,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                        bottom: 4,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Unit',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.currentProduct.dUnit,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: Icon(
                          //     Icons.edit,
                          //     color: Theme.of(context).primaryColor,
                          //   ),
                          // )
                        ],
                      ),
                    ),
//////////////////////////////////////////////////
                    Container(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                        bottom: 8,
                        // bottom: 8.0,
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Categories',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Wrap(
                              children: List.generate(3, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text(
                                      "It is a long establis",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                                return Chip(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  avatar: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Add category",
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(color: Colors.white),
                                  ),
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 24.0,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Price',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 8,
                        right: 0,
                      ),
                      child: CheckboxListTile(
                        title: Text('Availability'),
                        value: false,
                        onChanged: (value) {},
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.only(
                    //     top: 24.0,
                    //     left: 20,
                    //     right: 20,
                    //     // bottom: 8.0,
                    //   ),
                    //   alignment: Alignment.bottomLeft,
                    //   child: Text(
                    //     'Product Name',
                    //     style: Theme.of(context).textTheme.subtitle2,
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: Text(
                    //           "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', ",
                    //           overflow: TextOverflow.ellipsis,
                    //           style: Theme.of(context).textTheme.subtitle1,
                    //         ),
                    //       ),
                    //       IconButton(
                    //         onPressed: () {},
                    //         icon: Icon(
                    //           Icons.edit,
                    //           color: Theme.of(context).primaryColor,
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   padding: const EdgeInsets.only(
                    //     top: 24.0,
                    //     left: 20,
                    //     right: 20,
                    //   ),
                    //   alignment: Alignment.bottomLeft,
                    //   child: Text(
                    //     'Short description',
                    //     style: Theme.of(context).textTheme.subtitle2,
                    //   ),
                    // ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: <Widget>[
                    //     FlatButton(
                    //       onPressed: () {},
                    //       child: Text(
                    //         "+ Add short description",
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ),
                    //],
                    //),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
