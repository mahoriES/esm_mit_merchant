import 'package:flutter/material.dart';
import 'package:foore/check_in_page/check_in_page.dart';

import 'package:provider/provider.dart';

import 'package:foore/data/bloc/people.dart';
import '../app_translations.dart';
import 'unirson_list.dart';
import 'unirson_searchbar.dart';
import 'package:after_layout/after_layout.dart';

class PeoplePage extends StatefulWidget {
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage>
    with AfterLayoutMixin<PeoplePage> {
  @override
  void afterFirstLayout(BuildContext context) {
    final peopleBloc = Provider.of<PeopleBloc>(context);
    peopleBloc.getPeopleFromSearch();
  }

  onGetReviews() async {
    await CheckInPage.open(context);
  }

  @override
  Widget build(BuildContext context) {
    final peopleBloc = Provider.of<PeopleBloc>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.dehaze),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          AppTranslations.of(context).text("people_page_title"),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              UnirsonSearchBar(),
              Expanded(
                child: UnirsonListWidget(peopleBloc),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, -15),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 25,
          ),
          onPressed: this.onGetReviews,
          child: Container(
            child: Text(
              AppTranslations.of(context)
                  .text("review_page_button_get_reviews"),
              style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
