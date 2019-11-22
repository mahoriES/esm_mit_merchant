import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'dart:convert';

import 'model/google_locations.dart';

class SearchMapPlaceWidget extends StatefulWidget {
  SearchMapPlaceWidget({
    @required this.authBloc,
    this.onSelected,
    this.onSearch,
  });

  /// The callback that is called when one Place is selected by the user.
  final void Function(GoogleLocation place) onSelected;

  /// The callback that is called when the user taps on the search icon.
  final void Function(GoogleLocation place) onSearch;

  final AuthBloc authBloc;

  @override
  _SearchMapPlaceWidgetState createState() => _SearchMapPlaceWidgetState();
}

class _SearchMapPlaceWidgetState extends State<SearchMapPlaceWidget>
    with SingleTickerProviderStateMixin {
  TextEditingController _textEditingController = TextEditingController();
  AnimationController _animationController;
  // SearchContainer height.
  Animation _containerHeight;
  // Place options opacity.
  Animation _listOpacity;

  List<dynamic> _googleLocationPredictions = [];
  GoogleLocation _selectedGoogleLocation;

  final searchOnChange = new BehaviorSubject<String>();

  @override
  void initState() {
    _selectedGoogleLocation = null;
    _googleLocationPredictions = [];
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _containerHeight = Tween<double>(begin: 55, end: 420).animate(
      CurvedAnimation(
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
        parent: _animationController,
      ),
    );
    _listOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
        parent: _animationController,
      ),
    );
    widget.authBloc.googleSignIn.signInSilently(
      suppressErrors: false,
    );
    searchOnChange
        .debounceTime(Duration(seconds: 1))
        .listen((value) => _autocompletePlace(value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
        // width: MediaQuery.of(context).size.width * 0.9,
        child: _searchContainer(
          child: _searchInput(context),
        ),
      );

  // Widgets
  Widget _searchContainer({Widget child}) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Container(
            height: _containerHeight.value,
            decoration: _containerDecoration(context),
            padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 15),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: child,
                ),
                SizedBox(height: 10),
                Opacity(
                  opacity: _listOpacity.value,
                  child: Column(
                    children: <Widget>[
                      if (_googleLocationPredictions.length > 0)
                        for (var prediction in _googleLocationPredictions)
                          _placeOption(prediction),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _searchInput(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              decoration: _inputStyle(),
              controller: _textEditingController,
              // style:
              //     TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
              onChanged: (value) => searchOnChange.add(value),
            ),
          ),
          Container(width: 15),
          GestureDetector(
            child: Icon(Icons.search, color: Colors.blue),
            onTap: () => {
              if (widget.onSearch != null)
                {widget.onSearch(_selectedGoogleLocation)}
            },
          )
        ],
      ),
    );
  }

  Widget _placeOption(GoogleLocation prediction) {
    String locationName = prediction.location.locationName;

    return MaterialButton(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      onPressed: () => _selectPlace(prediction),
      child: ListTile(
        title: Text(
          locationName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          'Murgesh pallya , Airview coloney, Bangalore, karnataka aofafoa ,f aofam , india',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 0,
        ),
      ),
    );
  }

  // Styling
  InputDecoration _inputStyle() {
    return InputDecoration(
      hintText: "Search",
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
    );
  }

  BoxDecoration _containerDecoration(BuildContext context) {
    return BoxDecoration(
      // color: Theme.of(context).canvasColor,
      border: Border.all(width: 1.0, color: Colors.black45),
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
    );
  }

  // Methods
  void _autocompletePlace(String input) async {
    setState(() {});
    if (input.length > 5) {
      String url =
          "https://mybusiness.googleapis.com/v4/googleLocations:search";
      final body = '{"resultCount": 5,"query": "$input"}';
      final headers = await widget.authBloc.googleAuthHeaders;
      print(headers);
      final httpResponse = await http.post(
        url,
        body: body,
        headers: headers,
      );
      print(httpResponse.statusCode);
      print(httpResponse.body);
      var googleLocationsResponse =
          GoogleLocationsResponse.fromJson(json.decode(httpResponse.body));
      final predictions = googleLocationsResponse.googleLocations;
      await _animationController.animateTo(0.5);
      setState(() => _googleLocationPredictions = predictions);
      await _animationController.forward();
    } else if (input.length > 0) {
    } else {
      await _animationController.animateTo(0.5);
      setState(() => _googleLocationPredictions = []);
      await _animationController.reverse();
    }
  }

  void _selectPlace(GoogleLocation prediction) async {
    /// Will be called when a user selects one of the Place options.

    // // Sets TextField value to be the location selected
    // _textEditingController.value = TextEditingValue(
    //   text: prediction.location.locationName,
    //   selection: TextSelection.collapsed(
    //     offset: prediction.location.locationName.length,
    //   ),
    // );

    // Makes animation
    await _animationController.animateTo(0.5);
    setState(() {
      _googleLocationPredictions = [];
      _selectedGoogleLocation = prediction;
    });
    _animationController.reverse();

    // Calls the `onSelected` callback
    if (widget.onSelected != null) {
      widget.onSelected(prediction);
    }
  }
}
