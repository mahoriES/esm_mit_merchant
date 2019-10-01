import 'package:flutter/material.dart';
import 'package:foore/data/bloc/people.dart';
import 'package:foore/data/model/unirson.dart';
import 'package:foore/people_page/unisonItem.dart';
import 'package:foore/unirson_check_in_page/unirosn_check_in_page.dart';

class UnirsonListWidget extends StatelessWidget {
  final PeopleBloc _peopleBloc;

  UnirsonListWidget(this._peopleBloc);

  @override
  Widget build(BuildContext context) {
    onUnirsonSelected(UnirsonItem unirsonItem) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => UnirsonCheckInPage(unirsonItem),
            fullscreenDialog: true,
          ));
    }

    return StreamBuilder<PeopleState>(
        stream: this._peopleBloc.peopleStateObservable,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data.isLoadingFailed) {
              return Text('Loading Failed');
            } else if (snapshot.data.response != null) {
              return ListView(
                  padding: const EdgeInsets.only(top: 30),
                  children: snapshot.data.response.results.map((item) {
                    return UnirsonItemWidget(
                        unirsonItem: item,
                        onUnirsonSelected: onUnirsonSelected);
                  }).toList());
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
