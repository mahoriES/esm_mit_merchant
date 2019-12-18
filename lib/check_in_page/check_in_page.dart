import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/contacts_page/contacts_page.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/setting_page/sender_code.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/checkin_unirson.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/locations.dart';

import '../app_translations.dart';

class CheckInPage extends StatefulWidget {
  @override
  CheckInPageState createState() => CheckInPageState();

  static Future<bool> open(BuildContext context) async {
    return await Navigator.of(context).push(
      new MaterialPageRoute<bool>(
        builder: (BuildContext context) {
          return CheckInPage();
        },
        fullscreenDialog: true,
      ),
    );
  }
}

class CheckInPageState extends State<CheckInPage>
    with AfterLayoutMixin<CheckInPage> {
  final _formKey = GlobalKey<FormState>();
  HttpService _httpService;
  CheckinUnirsonBloc _checkinUnirsonBloc;
  StreamSubscription<CheckinUnirsonState> _subscription;
  bool shouldShowSmsCodeCustomize = false;

  openContactPicker() async {
    List<FoContact> results = await ContactsPage.open(context);
    if (results != null) {
      if (results.length == 1) {
        var contact = results[0];
        this
            ._checkinUnirsonBloc
            .setNameAndPhoneNumber(contact.name, contact.phoneNumber);
      } else if (results.length > 1) {
        this._checkinUnirsonBloc.setMultipleContacts(results);
      } else {
        this._checkinUnirsonBloc.removeMultipleContacts();
      }
    } else {
      this._checkinUnirsonBloc.removeMultipleContacts();
    }
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
    _subscription = this
        ._checkinUnirsonBloc
        .checkinStateObservable
        .listen(this._onCompleteVerificationStateChange);
    this._checkinUnirsonBloc.getData();

    final onboardingGuardBloc = Provider.of<OnboardingGuardBloc>(context);
    onboardingGuardBloc.shouldShowSmsCodeCustomize().then((shouldShow) {
      setState(() {
        this.shouldShowSmsCodeCustomize = shouldShow;
      });
    });
  }

  _onCompleteVerificationStateChange(
    CheckinUnirsonState state,
  ) {
    if (state.isSubmitFailed) {
      this._showFailedAlertDialog();
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  void didChangeDependencies() {
    this._httpService = Provider.of<HttpService>(context);
    if (this._checkinUnirsonBloc == null) {
      this._checkinUnirsonBloc = CheckinUnirsonBloc(this._httpService);
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    this._checkinUnirsonBloc.dispose();
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkInWithPhoneNumber() {
      if (_formKey.currentState.validate()) {
        this._checkinUnirsonBloc.checkinWithPhoneNumber(() async {
          await Future.delayed(Duration(milliseconds: 300));
          Navigator.of(context).pop(true);
        }); // Process data.

      }
    }

    checkInWithMultipleContacts() {
      if (_formKey.currentState.validate()) {
        this._checkinUnirsonBloc.checkinWithMultipleContacts(() async {
          await Future.delayed(Duration(milliseconds: 300));
          Navigator.of(context).pop(true);
        }); // Process data.

      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("checkin_page_title"),
        ),
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: StreamBuilder<CheckinUnirsonState>(
            stream: this._checkinUnirsonBloc.checkinStateObservable,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.data.isLoadingFailed) {
                  return SomethingWentWrong(
                    onRetry: this._checkinUnirsonBloc.getData,
                  );
                }
                return Scrollbar(
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                        visible: !snapshot.data.isMultipleContactsSelected,
                        child: checkInFormWidget(snapshot.data),
                      ),
                      Visibility(
                        visible: snapshot.data.isMultipleContactsSelected,
                        child: multipleContactsSelectedWidget(
                            snapshot.data, context),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 32.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          AppTranslations.of(context)
                              .text("checkin_page_select_a_store_to_check_in"),
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: DropdownButton<LocationItem>(
                          value: snapshot.data.selectedLocation,
                          elevation: 4,
                          onChanged:
                              this._checkinUnirsonBloc.setSelectedLocation,
                          items: snapshot.data.locations
                              .map<DropdownMenuItem<LocationItem>>(
                                  (LocationItem locationItem) {
                            return DropdownMenuItem<LocationItem>(
                              value: locationItem,
                              child: Text(locationItem.name),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 32.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          AppTranslations.of(context)
                              .text("checkin_page_feedback_and_google_review"),
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        alignment: Alignment.bottomLeft,
                        child: CheckboxListTile(
                          title: Text(AppTranslations.of(context).text(
                              "checkin_page_collect_feedback_and_review")),
                          value: snapshot.data.isGmbReviewSelected,
                          onChanged:
                              this._checkinUnirsonBloc.setIsGmbReviewSelected,
                        ),
                      ),
                      smsCodeWidget(context),
                      sequenceItemsWidget(snapshot.data),
                      SizedBox(
                        height: 60.0,
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            }),
      ),
      floatingActionButton: StreamBuilder<CheckinUnirsonState>(
          stream: this._checkinUnirsonBloc.checkinStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return FoSubmitButton(
              text: AppTranslations.of(context)
                  .text("checkin_page_button_submit"),
              onPressed: snapshot.data.isMultipleContactsSelected
                  ? checkInWithMultipleContacts
                  : checkInWithPhoneNumber,
              isLoading: snapshot.data.isSubmitting,
              isSuccess: snapshot.data.isSubmitSuccess,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Container multipleContactsSelectedWidget(
      CheckinUnirsonState data, BuildContext context) {
    return Container(
      child: Wrap(
          children: data.multipleContacts.map((contact) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Chip(
            label: Text(
              contact.name ?? contact.phoneNumber,
            ),
            onDeleted: () {
              this
                  ._checkinUnirsonBloc
                  .removeContactFromMultipleContacts(contact);
            },
          ),
        );
      }).toList()),
    );
  }

  Widget smsCodeWidget(BuildContext context) {
    if (shouldShowSmsCodeCustomize) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 16.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.green.withOpacity(0.1),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Text(
                  AppTranslations.of(context)
                      .text('check_in_page_sender_code_message'),
                  style: TextStyle(
                    color: Colors.green,
                    // decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(SenderCodePage.routeName);
              },
              child: Chip(
                elevation: 1,
                label: Text(
                  AppTranslations.of(context)
                      .text('check_in_page_sender_code_button'),
                  style: TextStyle(
                    color: Colors.white,
                    // decoration: TextDecoration.underline,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            )
          ],
        ),
      );
    } else
      return Container();
  }

  Container sequenceItemsWidget(CheckinUnirsonState state) {
    if (state.sequences.length == 0) {
      return Container();
    }
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 32.0,
              left: 16.0,
              right: 16.0,
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              AppTranslations.of(context)
                  .text("checkin_page_subscribe_contact_to_sequences"),
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Container(
            child: Column(
              children: state.sequences.map((sequence) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  alignment: Alignment.bottomLeft,
                  child: CheckboxListTile(
                    title: Text(sequence.sequenceName),
                    value: sequence.isSelectedUi != null
                        ? sequence.isSelectedUi
                        : false,
                    onChanged: (bool value) {
                      this
                          ._checkinUnirsonBloc
                          .setSequenceSelected(sequence, value);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Container checkInFormWidget(CheckinUnirsonState state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20),
          TextFormField(
            controller: this._checkinUnirsonBloc.nameEditController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText:
                  AppTranslations.of(context).text("checkin_page_name_label"),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: this._checkinUnirsonBloc.phoneNumberEditController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: AppTranslations.of(context)
                  .text("checkin_page_phone_number_label"),
            ),
            validator: (String value) {
              return value.length < 1
                  ? AppTranslations.of(context)
                      .text("checkin_page_phone_number_validation")
                  : null;
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.only(left: 8.0),
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
                  onTap: this.openContactPicker,
                  child: Chip(
                    onDeleted: this.openContactPicker,
                    label: Text(
                      'Select from Contacts',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    deleteIcon: Icon(Icons.add, size: 16.0),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
