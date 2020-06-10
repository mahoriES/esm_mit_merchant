import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';

class AddMenuItemPage extends StatefulWidget {
  static const routeName = '/add-menu-item';

  AddMenuItemPage();

  @override
  AddMenuItemPageState createState() => AddMenuItemPageState();
}

class AddMenuItemPageState extends State<AddMenuItemPage>
    with AfterLayoutMixin<AddMenuItemPage> {
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
          'Add Item',
        ),
      ),
      body: Form(
          key: _formKey,
          onWillPop: _onWillPop,
          child: Scrollbar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 20),
                  Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Container(
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width - 40,
                        color: Colors.grey[100],
                        child: Center(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Add a product photo',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            )
                          ],
                        )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Product name',
                    ),
                    validator: (String value) {
                      return value.length < 1 ? 'Invalid' : null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Product category',
                    ),
                    validator: (String value) {
                      return value.length < 1 ? 'Invalid' : null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Price (INR)',
                    ),
                    validator: (String value) {
                      return value.length < 1 ? 'Invalid' : null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    maxLines: 4,
                    minLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Product description',
                    ),
                    validator: (String value) {
                      return value.length < 1 ? 'Invalid' : null;
                    },
                  ),
                ],
              ),
            ),
          )),
      floatingActionButton: FoSubmitButton(
        text: 'Save',
        onPressed: submit,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
