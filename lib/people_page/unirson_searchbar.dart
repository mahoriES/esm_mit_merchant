import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/people.dart';
import 'package:provider/provider.dart';

import '../app_translations.dart';

class UnirsonSearchBar extends StatefulWidget {

  @override
  _UnirsonSearchBarState createState() => _UnirsonSearchBarState();
}

class _UnirsonSearchBarState extends State<UnirsonSearchBar> with AfterLayoutMixin<UnirsonSearchBar> {
  final searchController = TextEditingController();

   @override
  void afterFirstLayout(BuildContext context) {
    final peopleBloc = Provider.of<PeopleBloc>(context);
     this.searchController.addListener(() {
      peopleBloc.onSearchTextChanged(this.searchController);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    this.searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peopleBloc = Provider.of<PeopleBloc>(context);
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
