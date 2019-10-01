import 'package:flutter/material.dart';
import 'package:foore/data/bloc/people.dart';

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
      child: TextField(
        controller: searchController,
        style: TextStyle(
          color: Colors.black54,
        ),
        cursorColor: Colors.black54,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromARGB(80, 233, 233, 233),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide(
              color: Colors.white,
              style: BorderStyle.solid,
            ),
            gapPadding: 10.0,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide(
              color: Colors.white,
              style: BorderStyle.solid,
            ),
            gapPadding: 10.0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide(
              color: Colors.white,
              style: BorderStyle.solid,
            ),
            gapPadding: 10.0,
          ),
          labelText: 'Search people',
          labelStyle: TextStyle(
            color: Colors.black54,
          ),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
