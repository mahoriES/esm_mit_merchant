import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_address_bloc.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

class SearchAddressView extends StatefulWidget {
  static const String routeName = "addressSearchView";
  SearchAddressView({
    Key key,
  }) : super(key: key);

  @override
  _SearchAddressViewState createState() => _SearchAddressViewState();
}

class _SearchAddressViewState extends State<SearchAddressView> {
  TextEditingController addressController = new TextEditingController();

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EsAddressBloc _esAddressBloc =
        Provider.of<EsAddressBloc>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("address_page_search_location"),
          style: AppTextStyles.topTileTitle,
        ),
      ),
      body: StreamBuilder<EsAddressState>(
        stream: _esAddressBloc.esAddressStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();

          if (snapshot.data.suggestionsStatus == LaodingStatus.SUCCESS) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              _esAddressBloc.resetSearchDetails();
              Navigator.popUntil(context, ModalRoute.withName("/AddressView"));
            });
          }

          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: 12.toWidth, vertical: 12.toHeight),
            child: Column(
              children: [
                TypeAheadField<Prediction>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.placeHolderColor,
                        ),
                      ),
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  suggestionsCallback: (input) async =>
                      await _esAddressBloc.getSuggestions(input, context),
                  onSuggestionSelected: (Prediction suggestion) async {
                    await _esAddressBloc.getPlaceDetails(suggestion.placeId);
                  },
                  itemBuilder: (context, Prediction suggestion) {
                    return ListTile(
                      title: Text(suggestion.description),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
