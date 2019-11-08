import 'package:flutter/material.dart';
import 'package:foore/data/bloc/people.dart';

import '../app_translations.dart';

class UnirsonSearchBar extends StatefulWidget {
  final PeopleBloc _peopleBloc;

  UnirsonSearchBar(
    this._peopleBloc, {
    Key key,
  }) : super(key: key) {
    this._peopleBloc.toString();
  }

  @override
  _UnirsonSearchBarState createState() => _UnirsonSearchBarState();
}

class _UnirsonSearchBarState extends State<UnirsonSearchBar> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.searchController.addListener(() {
      this.widget._peopleBloc.onSearchTextChanged(this.searchController);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    this.searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.only(
          left: 22.0,
          right: 8.0,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            labelText:
                AppTranslations.of(context).text("people_page_search_label"),
            suffixIcon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}
