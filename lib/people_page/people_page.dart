import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/check_in_page/check_in_page.dart';
import 'package:foore/data/bloc/people.dart';
import 'package:foore/data/http_service.dart';
import 'unirson_list.dart';
import 'unirson_searchbar.dart';

class PeoplePage extends StatefulWidget {
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  PeopleBloc _peopleBloc;

  @override
  void didChangeDependencies() {
    final httpService = Provider.of<HttpService>(context);
    this._peopleBloc = PeopleBloc(httpService);
    this._peopleBloc.getPeopleFromSearch();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this._peopleBloc.dispose();
    super.dispose();
  }

  onGetReviews() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => CheckInPage(),
          fullscreenDialog: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        textTheme: Typography.blackMountainView,
        iconTheme: IconThemeData.fallback(),
        leading: IconButton(
          icon: Icon(Icons.dehaze),
          color: Colors.black54,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          'People',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 24.0,
            letterSpacing: 1.1,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: RaisedButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(50.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                color: Colors.blue,
                onPressed: this.onGetReviews,
                child: Container(
                  child: Text(
                    'New Check In',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
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
              new UnirsonSearchBar(this._peopleBloc),
              Expanded(
                child: UnirsonListWidget(this._peopleBloc),
              )
            ],
          ),
        ),
      ),
    );
  }
}
