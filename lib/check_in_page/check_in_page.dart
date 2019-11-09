import 'dart:async';
import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/checkin_unirson.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/locations.dart';

import '../app_translations.dart';

class CheckInPage extends StatefulWidget {
  CheckInPage();

  @override
  CheckInPageState createState() => CheckInPageState();
}

class CheckInPageState extends State<CheckInPage> {
  final _formKey = GlobalKey<FormState>();
  HttpService _httpService;
  CheckinUnirsonBloc _checkinUnirsonBloc;

  final ContactPicker _contactPicker = new ContactPicker();

  onContactPicked() async {
    Contact contact = await _contactPicker.selectContact();
    this
        ._checkinUnirsonBloc
        .setNameAndPhoneNumber(contact.fullName, contact.phoneNumber.number);
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
      this._checkinUnirsonBloc.getData();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkIn() {
      if (_formKey.currentState.validate()) {
        this._checkinUnirsonBloc.checkinWithPhoneNumber(() {
          Navigator.pop(context);
        }); // Process data.

      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("checkin_page_title"),
        ),
        actions: <Widget>[
          StreamBuilder<CheckinUnirsonState>(
              stream: this._checkinUnirsonBloc.checkinStateObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return FlatButton(
                  onPressed: checkIn,
                  child: Container(
                    child: Center(
                      child: snapshot.data.isSubmitting
                          ? Center(
                              child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            ))
                          : Text(AppTranslations.of(context)
                              .text("checkin_page_button_submit")),
                    ),
                  ),
                );
              }),
        ],
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
                  return Text('Loading Failed');
                }
                return Scrollbar(
                  child: ListView(
                    children: <Widget>[
                      checkInFormWidget(snapshot.data),
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
                            horizontal: 16.0, vertical: 4.0),
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
                      sequenceItemsWidget(snapshot.data),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            }),
      ),
    );
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          TextFormField(
            controller: this._checkinUnirsonBloc.nameEditController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText:
                  AppTranslations.of(context).text("checkin_page_name_label"),
              suffixIcon: IconButton(
                onPressed: this.onContactPicked,
                icon: Icon(Icons.contacts),
              ),
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
        ],
      ),
    );
  }
}
