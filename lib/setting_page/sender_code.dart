import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';

import '../app_translations.dart';

class SenderCodePage extends StatefulWidget {
  static const routeName = '/sender-code';
  @override
  SenderCodePageState createState() => SenderCodePageState();

  static Route generateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => SenderCodePage());
  }
}

class SenderCodePageState extends State<SenderCodePage>
    with AfterLayoutMixin<SenderCodePage> {
  FocusNode _codeFocusNodeOne;
  FocusNode _codeFocusNodeTwo;
  FocusNode codeFocusNodeThree;
  FocusNode codeFocusNodeFour;
  FocusNode codeFocusNodeFive;
  FocusNode codeFocusNodeSix;
  bool isManual = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  void initState() {
    super.initState();
    _codeFocusNodeOne = FocusNode();
    _codeFocusNodeTwo = FocusNode();
    codeFocusNodeThree = FocusNode();
    codeFocusNodeFour = FocusNode();
    codeFocusNodeFive = FocusNode();
    codeFocusNodeSix = FocusNode();
  }

  @override
  void dispose() {
    _codeFocusNodeOne.dispose();
    _codeFocusNodeTwo.dispose();
    codeFocusNodeThree.dispose();
    codeFocusNodeFour.dispose();
    codeFocusNodeFive.dispose();
    codeFocusNodeSix.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    manualCodeChange() {
      if (_formKey.currentState.validate()) {
        // this._checkinUnirsonBloc.checkinWithPhoneNumber(() async {
        //   await Future.delayed(Duration(milliseconds: 300));
        //   Navigator.of(context).pop(true);
        // }); // Process data.
      }
    }

    suggestedCodeChange() {
      if (_formKey.currentState.validate()) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sender Code',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
        elevation: 0,
        brightness: Brightness.dark,
        iconTheme: IconThemeData.fallback().copyWith(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 45.0,
          ),
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  color: Colors.blue,
                  height: 250.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 50.0,
                  ),
                  child: Container(
                    height: 200.0,
                    child: Center(
                      child: Image(
                        image: AssetImage('assets/sms-code.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
              ),
              child: Text(
                'Choose a sender code that matches your brand name. It increases click rate.',
                style: Theme.of(context).textTheme.body1.copyWith(
                      color: Colors.green,
                    ),
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
              child: Text('Change Sender Code'),
            ),
            Visibility(
              visible: !isManual,
              child: Container(
                child: Column(
                  children: <Widget>[
                    CheckboxListTile(
                      title: Text('oFoore'),
                      value: true,
                      onChanged: (bool value) {},
                    ),
                    CheckboxListTile(
                      title: Text('oFoore'),
                      value: false,
                      onChanged: (bool value) {},
                    ),
                    CheckboxListTile(
                      title: Text('oFoore'),
                      value: false,
                      onChanged: (bool value) {},
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'or',
                            style: Theme.of(context).textTheme.caption,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isManual = true;
                              });
                            },
                            child: Chip(
                              label: Text(
                                'Enter manually',
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: isManual,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: _codeFocusNodeOne,
                        onChanged: (String text) {
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(_codeFocusNodeTwo);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: _codeFocusNodeTwo,
                        onChanged: (String text) {
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(codeFocusNodeThree);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: codeFocusNodeThree,
                        onChanged: (String text) {
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(codeFocusNodeFour);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: codeFocusNodeFour,
                        onChanged: (String text) {
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(codeFocusNodeFive);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: codeFocusNodeFive,
                        onChanged: (String text) {
                          if (text.length > 0) {
                            FocusScope.of(context)
                                .requestFocus(codeFocusNodeSix);
                          }
                        },
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Container(),
                        ),
                        focusNode: codeFocusNodeSix,
                        maxLength: 1,
                        validator: (String value) {
                          return value.length < 1 ? '' : null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FoSubmitButton(
        text: AppTranslations.of(context).text("checkin_page_button_submit"),
        onPressed: isManual ? manualCodeChange : suggestedCodeChange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
