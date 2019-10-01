import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/data/bloc/checkin_unirson.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/locations.dart';
import 'package:foore/data/model/unirson.dart';
import 'package:foore/people_page/unisonItem.dart';

class UnirsonCheckInPage extends StatefulWidget {
  final UnirsonItem _unirsonItem;

  UnirsonCheckInPage(this._unirsonItem);

  @override
  UnirsonCheckInPageState createState() => UnirsonCheckInPageState();
}

class UnirsonCheckInPageState extends State<UnirsonCheckInPage> {
  final _formKey = GlobalKey<FormState>();
  HttpService _httpService;
  CheckinUnirsonBloc _checkinUnirsonBloc;

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  void didChangeDependencies() {
    this._httpService = Provider.of<HttpService>(context);
    this._checkinUnirsonBloc = CheckinUnirsonBloc(this._httpService);
    this._checkinUnirsonBloc.getData();
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
      this._checkinUnirsonBloc.checkin(unirsonItem.unirsonId, () {
        Navigator.pop(context);
      });
    }

    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        textTheme: Typography.blackMountainView,
        iconTheme: IconThemeData.fallback(),
        title: Text(
          'Check In',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 24.0,
            letterSpacing: 1.1,
          ),
        ),
         elevation: 0.0,
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
                          : Text(
                              'SUBMIT',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
                      UnirsonItemWidget(unirsonItem: unirsonItem),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 32.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Select a store to Check In',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: DropdownButton<LocationItem>(
                          value: snapshot.data.selectedLocation,
                          elevation: 4,
                          style: TextStyle(color: Colors.black87),
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
                          'Feedback and Google Review',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        alignment: Alignment.bottomLeft,
                        child: CheckboxListTile(
                          title: const Text('Collect Feedback and Review'),
                          value: snapshot.data.isGmbReviewSelected,
                          onChanged:
                              this._checkinUnirsonBloc.setIsGmbReviewSelected,
                        ),
                      ),
                      sequenceItemsWidget(snapshot),
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
              'Subscribe contact to message sequences',
              style: TextStyle(color: Colors.black54),
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
