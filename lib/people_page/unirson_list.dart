import 'package:flutter/material.dart';
import 'package:foore/data/bloc/people.dart';
import 'package:foore/data/model/unirson.dart';
import 'package:foore/people_page/unisonItem.dart';
import 'package:foore/unirson_check_in_page/unirson_check_in_page.dart';
import 'package:foore/widgets/empty_list.dart';
import 'package:foore/widgets/something_went_wrong.dart';

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
              return SomethingWentWrong(
                onRetry: this._peopleBloc.getPeopleFromSearch,
              );
            } else if (snapshot.data.items.length == 0) {
              return EmptyList(
                titleText: 'No customers found',
                subtitleText: "Press 'Get reviews' to add new customers",
              );
            } else {
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    this._peopleBloc.loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: 72,
                      top: 30,
                    ),
                    itemCount: snapshot.data.items.length + 1,
                    itemBuilder: (context, index) {
                      if (snapshot.data.items.length == index) {
                        if (snapshot.data.isLoadingMore) {
                          return Container(
                            margin: EdgeInsets.all(4.0),
                            height: 36,
                            width: 36,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }
                      return UnirsonItemWidget(
                          unirsonItem: snapshot.data.items[index],
                          onUnirsonSelected: onUnirsonSelected);
                    }),
              );
            }
          }
          return Container();
        });
  }
}
