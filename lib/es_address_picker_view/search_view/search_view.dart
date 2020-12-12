import 'package:flutter/material.dart';
import 'package:foore/app_colors.dart';
import 'package:foore/data/bloc/es_address_bloc.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:foore/utils/extensions.dart';
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
  @override
  Widget build(BuildContext context) {
    EsAddressBloc _esAddressBloc =
        Provider.of<EsAddressBloc>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "address_page_search_location".localize,
          style: AppTextStyles.topTileTitle,
        ),
      ),
      body: StreamBuilder<EsAddressState>(
        stream: _esAddressBloc.esAddressStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink();

          if (snapshot.data.suggestionsStatus == LaodingStatus.SUCCESS) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pop(context);
              _esAddressBloc.resetSearchDetails();
            });
          }

          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: 12.toWidth, vertical: 12.toHeight),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.placeHolderColor,
                      ),
                    ),
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (input) async {
                    if (input.trim() != "" &&
                        snapshot.data.suggestionsStatus !=
                            LaodingStatus.LOADING) {
                      _esAddressBloc.getSuggestions(input);
                    }
                  },
                ),
                SizedBox(height: 12.toHeight),
                if (snapshot.data.suggestionsStatus !=
                    LaodingStatus.LOADING) ...[
                  ListView.builder(
                    itemCount: snapshot
                            .data.placesSearchResponse?.predictions?.length ??
                        0,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () => _esAddressBloc.getPlaceDetails(
                            snapshot.data.placesSearchResponse
                                ?.predictions[index].placeId,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.toWidth,
                              vertical: 12.toHeight,
                            ),
                            child: Text(
                              ((snapshot.data.placesSearchResponse?.predictions
                                              ?.length ??
                                          0) >
                                      index)
                                  ? snapshot.data.placesSearchResponse
                                      ?.predictions[index]?.description
                                  : "dummy",
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
