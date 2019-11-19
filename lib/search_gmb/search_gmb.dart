import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    _selectedGoogleLocation = null;
    _googleLocationPredictions = [];
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _containerHeight = Tween<double>(begin: 55, end: 360).animate(
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width * 0.9,
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
            decoration: _containerDecoration(),
            padding: EdgeInsets.only(left: 0, right: 0, top: 15),
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
              style:
                  TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
              onChanged: (value) => setState(() => _autocompletePlace(value)),
            ),
          ),
          Container(width: 15),
          GestureDetector(
            child: Icon(Icons.search, color: Colors.blue),
            onTap: () => widget.onSearch(_selectedGoogleLocation),
          )
        ],
      ),
    );
  }

  Widget _placeOption(GoogleLocation prediction) {
    String place = prediction.location.locationName;

    return MaterialButton(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      onPressed: () => _selectPlace(prediction),
      child: ListTile(
        title: Text(
          place.length < 45
              ? "$place"
              : "${place.replaceRange(45, place.length, "")} ...",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
          maxLines: 1,
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
      contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10)
      ],
    );
  }

  // Methods
  void _autocompletePlace(String input) async {
    /// Will be called everytime the input changes. Making callbacks to the Places
    /// Api and giving the user Place options

    if (input.length > 0) {
      String url =
          "https://mybusiness.googleapis.com/v4/googleLocations:search";
      final body = '{"resultCount": 10,"query": "$input"}';
      final headers = await widget.authBloc.googleAuthHeaders;
      final httpResponse = await http.post(
        url,
        body: body,
        headers: headers,
      );
      var googleLocationsResponse =
          GoogleLocationsResponse.fromJson(json.decode(httpResponse.body));
      final predictions = googleLocationsResponse.googleLocations;
      await _animationController.animateTo(0.5);
      setState(() => _googleLocationPredictions = predictions);
      await _animationController.forward();
    } else {
      await _animationController.animateTo(0.5);
      setState(() => _googleLocationPredictions = []);
      await _animationController.reverse();
    }
  }

  void _selectPlace(GoogleLocation prediction) async {
    /// Will be called when a user selects one of the Place options.

    // Sets TextField value to be the location selected
    _textEditingController.value = TextEditingValue(
      text: prediction.location.locationName,
      selection: TextSelection.collapsed(
        offset: prediction.location.locationName.length,
      ),
    );

    // Makes animation
    await _animationController.animateTo(0.5);
    setState(() {
      _googleLocationPredictions = [];
      _selectedGoogleLocation = prediction;
    });
    _animationController.reverse();

    // Calls the `onSelected` callback
    widget.onSelected(prediction);
  }
}
