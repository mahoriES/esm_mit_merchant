import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/checkin_unirson.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/locations.dart';
import 'package:foore/data/model/unirson.dart';
import 'package:foore/people_page/unisonItem.dart';

import '../app_translations.dart';

class UnirsonCheckInPage extends StatefulWidget {
  static const routeName = '/unirson-checkin';
  final UnirsonItem _unirsonItem;

  UnirsonCheckInPage(this._unirsonItem);

  @override
  UnirsonCheckInPageState createState() => UnirsonCheckInPageState();
}

class UnirsonCheckInPageState extends State<UnirsonCheckInPage>
    with AfterLayoutMixin<UnirsonCheckInPage> {
  final _formKey = GlobalKey<FormState>();
  HttpService _httpService;
  CheckinUnirsonBloc _checkinUnirsonBloc;
  StreamSubscription<CheckinUnirsonState> _subscription;

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
    _subscription = this
        ._checkinUnirsonBloc
        .checkinStateObservable
        .listen(this._onCompleteVerificationStateChange);
    this._checkinUnirsonBloc.getData();
  }

  _onCompleteVerificationStateChange(
    CheckinUnirsonState state,
  ) {
    if (state.isSubmitFailed) {
      this._showFailedAlertDialog();
    }
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
    final UnirsonItem unirsonItem = this.widget._unirsonItem;

    checkIn() {
      this._checkinUnirsonBloc.checkin(unirsonItem.unirsonId, () async {
        await Future.delayed(Duration(milliseconds: 300));
        Navigator.pop(context);
      });
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
                      UnirsonItemWidget(unirsonItem: unirsonItem),
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
                      sequenceItemsWidget(snapshot),
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
              onPressed: checkIn,
              isLoading: snapshot.data.isSubmitting,
              isSuccess: snapshot.data.isSubmitSuccess,
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Container sequenceItemsWidget(AsyncSnapshot<CheckinUnirsonState> snapshot) {
    if (snapshot.data.sequences.length == 0) {
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
              children: snapshot.data.sequences.map((sequence) {
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
}
