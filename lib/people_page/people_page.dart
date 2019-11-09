import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foore/check_in_page/check_in_page.dart';
import 'package:foore/data/bloc/people.dart';
import 'package:foore/data/http_service.dart';
import '../app_translations.dart';
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
    if (this._peopleBloc == null) {
      this._peopleBloc = PeopleBloc(httpService);
      this._peopleBloc.getPeopleFromSearch();
    }
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
                  child: Text(AppTranslations.of(context)
                      .text("people_page_button_check_in")),
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
