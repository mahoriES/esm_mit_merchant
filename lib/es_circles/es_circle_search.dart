import 'package:circles/circles.dart';
import 'package:circles/themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_select_circle.dart';
import 'package:foore/es_circles/es_circle_picker_view.dart';

class CircleSearchView extends StatefulWidget {
  static const routeName = "/circleSearchView";

  @override
  _CircleSearchViewState createState() => _CircleSearchViewState();
}

class _CircleSearchViewState extends State<CircleSearchView> {
  EsSelectCircleBloc _esSelectCircleBloc;

  @override
  void initState() {
//    _esSelectCircleBloc =
//        ModalRoute.of(context).settings.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _esSelectCircleBloc =
        ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<EsSelectCircleState>(
          stream: _esSelectCircleBloc.selectCircleObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();
            return Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    onChanged: (text) {
                      if (text.isNotEmpty)
                        _esSelectCircleBloc.getSearchResultsCircles();
                    },
                    controller:
                        _esSelectCircleBloc.circleSearchTextFieldController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: ('circle.search'),
                      hintStyle: CustomTheme.of(context)
                          .themeData
                          .textTheme
                          .subtitle1
                          .copyWith(
                              color: CustomTheme.of(context)
                                  .colors
                                  .disabledAreaColor),
                      prefixIcon: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: CustomTheme.of(context).colors.primaryColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                CustomTheme.of(context).colors.shadowColor16),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                CustomTheme.of(context).colors.shadowColor16),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.all(0.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                if (snapshot.data.searchResultsLoading !=
                    LoadingStatus.LOADING) ...[
                  if (snapshot.data.searchResultsCircles.isEmpty)
                    circleInfoProviderWidget,
                  if (snapshot.data.searchResultsCircles.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        child: CircleTileGridView(
                            tilesDataList: snapshot.data.searchResultsCircles
                                .toCircleTileList(),
                            onDelete: null,
                            onTap: (circleCode) {
                              _esSelectCircleBloc.setCirclesAsSelected(circleCode);
                              Navigator.pop(context);
                            }),
                      ),
                    )
                ] else
                  const CirclesLoadingIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget get circleInfoProviderWidget => Padding(
        padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
        child: Text(
          "Try searching for a Circle by typing in your city name. For e.g. Udupi, Chandigarh.",
          style: CustomTheme.of(context).textStyles.sectionHeading1.copyWith(
              color: CustomTheme.of(context).colors.disabledAreaColor),
          textAlign: TextAlign.center,
        ),
      );
}
