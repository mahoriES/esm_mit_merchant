import 'package:flutter/material.dart';
import 'package:foore/data/bloc/people.dart';
import 'package:foore/data/model/unirson.dart';
import 'package:foore/people_page/unisonItem.dart';
import 'package:foore/unirson_check_in_page/unirson_check_in_page.dart';

class UnirsonListWidget extends StatelessWidget {
  final PeopleBloc _peopleBloc;

  UnirsonListWidget(this._peopleBloc);

  @override
  Widget build(BuildContext context) {
    onUnirsonSelected(UnirsonItem unirsonItem) {
      Navigator.pushNamed(
        context,
        UnirsonCheckInPage.routeName,
        arguments: unirsonItem,
      );
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
            } else {
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    this._peopleBloc.loadMore();
                  }
                  return false;
                },
                child: ListView(
                    padding: const EdgeInsets.only(top: 30),
                    children: snapshot.data.items.map((item) {
                      return UnirsonItemWidget(
                          unirsonItem: item,
                          onUnirsonSelected: onUnirsonSelected);
                    }).toList()),
              );
            }
          }
          return Container();
        });
  }
}
