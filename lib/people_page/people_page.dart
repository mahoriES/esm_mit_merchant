import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/check_in_page/check_in_page.dart';
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

  onGetReviews() {
    Navigator.pushNamed(context, CheckInPage.routeName);
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
      floatingActionButton: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 25,
        ),
        color: Colors.blue,
        onPressed: this.onGetReviews,
        child: Container(
          child: Text(
            AppTranslations.of(context).text("people_page_button_check_in"),
            style: Theme.of(context).textTheme.subhead.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
