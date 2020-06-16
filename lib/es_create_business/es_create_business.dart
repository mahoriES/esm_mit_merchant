import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';

class EsCreateBusinessPage extends StatefulWidget {
  static const routeName = '/create-business';

  EsCreateBusinessPage();

  @override
  EsCreateBusinessPageState createState() => EsCreateBusinessPageState();
}

class EsCreateBusinessPageState extends State<EsCreateBusinessPage>
    with AfterLayoutMixin<EsCreateBusinessPage> {
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
  void afterFirstLayout(BuildContext context) {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    submit() {}

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create business',
        ),
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: Scrollbar(
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Material(
                      elevation: 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          height: 120,
                          width: 120,
                          child: Container(
                            child: Image.network('https://picsum.photos/200'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Material(
                      elevation: 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          height: 120,
                          width: 120,
                          child: Container(
                            child: Image.network('https://picsum.photos/200'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          height: 120,
                          width: 120,
                          color: Colors.grey[100],
                          child: Center(
                            child: Icon(
                              Icons.add_a_photo,
                              // size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                    labelText: 'Product name',
                  ),
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
                    labelText: 'Short description',
                  ),
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
                    labelText: 'Long description',
                  ),
                ),
              ),
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
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(
                                "It is a long establis",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(
                                "It is a long establis",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Chip(
                            backgroundColor: Theme.of(context).primaryColor,
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
                          ),
                        ],
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
      ),
      floatingActionButton: FoSubmitButton(
        text: 'Save',
        onPressed: submit,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
