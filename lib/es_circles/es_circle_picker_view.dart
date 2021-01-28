import 'package:circles/secret_circle_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_select_circle.dart';
import 'package:foore/data/model/es_clusters.dart';
import 'package:foore/es_circles/es_circle_search.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:provider/provider.dart';
import 'package:circles/themes/custom_theme.dart';
import 'package:circles/circles.dart';

class CirclePickerView extends StatefulWidget {
  static const routeName = "/circlePickerView";

  @override
  _CirclePickerViewState createState() => _CirclePickerViewState();
}

class _CirclePickerViewState extends State<CirclePickerView> {
  EsSelectCircleBloc _esSelectCircleBloc;

  void onAddCallback(String circleCode) {
    ///
    ///This condition check won't be actually required as the bottom sheet doesn't close
    ///if text field is empty, but still an additional check is okay!
    ///
    if (circleCode.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter a valid code!");
      return;
    }
    Navigator.pop(context, EsCluster(clusterCode: circleCode,
        clusterId: '',
        clusterName: circleCode,
        description: 'Circle added via Code'));
  }

  @override
  void initState() {
    _esSelectCircleBloc =
        Provider.of<EsSelectCircleBloc>(context, listen: false);
    _esSelectCircleBloc.getTrendingCircles();
    _esSelectCircleBloc.getNearbyCircles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (SizeConfig().screenWidth == null) SizeConfig().init(context);
    const locationPointerImage = "assets/location-pointer.png";
    return CustomTheme(initialThemeType: THEME_TYPES.LIGHT,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: CircleTopBannerView(),
        floatingActionButton: StreamBuilder<EsSelectCircleState>(
            stream: _esSelectCircleBloc.selectCircleObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              return Opacity(
                opacity: snapshot.data.selectedCircle == null ? 0.0 : 1.0,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pop(context, snapshot.data.selectedCircle);
                  },
                  label: Text(
                      'Select ${snapshot.data.selectedCircle?.clusterName ??
                          ''}'),
                ),
              );
            }),
        body: StreamBuilder<EsSelectCircleState>(
            stream: _esSelectCircleBloc.selectCircleObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              return SingleChildScrollView(
                child: Column(
                  children: [
                    CirclesSearchBar(onTap: () {
                      Navigator.of(context).pushNamed(
                          CircleSearchView.routeName,
                          arguments: _esSelectCircleBloc);
                    }),
                    TrendingCirclesCarouselView(
                      trendingCirclesLabelLocalisedString: AppTranslations.of(context).text('trending_circles'),
                      onTap: _esSelectCircleBloc.setCirclesAsSelected,
                      trendingCirclesList:
                      snapshot.data?.trendingCircles?.toCircleTileList() ??
                          [],
                    ),
                    snapshot.data.nearbyCirclesLoading == LoadingStatus.LOADING
                        ? const CirclesLoadingIndicator()
                        : SuggestedNearbyCirclesView(
                      onSelectCircle:
                      _esSelectCircleBloc.setCirclesAsSelected,
                      onTapLocationAction: () {
                        _esSelectCircleBloc.onTapLocationAction();
                      },
                      isLocationDisabled: !snapshot.data.locationEnabled,
                      suggestedCirclesList: snapshot.data?.nearbyCircles
                          ?.toCircleTileList() ??
                          [],
                      suggestedCircleLabelLocalisedString:
                      AppTranslations.of(context).text('suggested_circles'),
                      turnOnLocationLocalisedString: AppTranslations.of(context).text('turn_on_location'),
                      circleLocationLocalisedString:
                      AppTranslations.of(context).text('turn_on_location_msg'),
                      locationPointerImagePath: locationPointerImage,
                      nearbyCircleLabelLocalisedString:
                      AppTranslations.of(context).text('based_on_current_location'),
                    ),
                    CircleInfoFooter(
                        onTapCallBack: () =>
                            showSecretCircleAdderDialog(context, onAddCallback),
                        isAdvancedUser: () =>
                            _esSelectCircleBloc.isAdvancedUser(),
                        circleBrandingLocalisedText: AppTranslations.of(context).text('esamudaay_circles'),
                        circleInfo1LocalisedText:
                        AppTranslations.of(context).text('circle_info_1'),
                        circleInfo2LocalisedText:
                        AppTranslations.of(context).text('circle_info_2'),
                        setCurrentUserAsAdvancedCallback: () =>
                            _esSelectCircleBloc.setCurrentUserAsAdvanced()),
                  ],
                ),
              );
            }),
      ),
    );
  }

  void showSecretCircleAdderDialog(BuildContext context,
      Function onAddCallback) {
    showDialog(
        context: context,
        builder: (context) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: CustomTheme(initialThemeType: THEME_TYPES.LIGHT,
              child: SecretCircleBottomSheet(
                onAddCircle: onAddCallback,
                circleEnterCodeLocalisedString: AppTranslations.of(context).text('enter_circle_code'),
              ),
            ),
          );
        });
  }
}

class CirclesLoadingIndicator extends StatelessWidget {
  const CirclesLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig().screenHeight / 4,
      width: SizeConfig().screenWidth,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class CircleTopBannerView extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  CircleTopBannerView({Key key})
      : preferredSize = Size.fromHeight(134 / 375 * SizeConfig().screenWidth),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 6.0,
            color: CustomTheme
                .of(context)
                .colors
                .shadowColor16)
      ]),
      child: SizedBox(
        width: SizeConfig().screenWidth,
        child: AspectRatio(
          aspectRatio: 375 / 134,
          child: Stack(
            children: [
              Positioned.fill(child: getGradientContainer(context)),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: buildCustomOverChild(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getGradientContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomTheme
                .of(context)
                .colors
                .storeCoreColor,
            CustomTheme
                .of(context)
                .colors
                .secondaryColor,
            CustomTheme
                .of(context)
                .colors
                .primaryColor,
          ],
          stops: [0.0, 0.35, 1.0],
        ),
      ),
    );
  }

  Widget buildCustomOverChild(BuildContext context) {
    return SizedBox(
      width: SizeConfig().screenWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/es-logo.png',
              width: 134.5 / 375 * SizeConfig().screenWidth,
              color: CustomTheme
                  .of(context)
                  .colors
                  .backgroundColor,
            ),
          ],
        ),
      ),
    );
  }
}

class CirclesSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const CirclesSearchBar({Key key, @required this.onTap})
      : assert(onTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 23),
      child: Container(
        child: InkWell(
          onTap: onTap,
          child: IgnorePointer(
            child: TextField(
              decoration: InputDecoration(
                hintText: AppTranslations.of(context).text("circle_search_action_hint"),
                hintStyle: CustomTheme
                    .of(context)
                    .themeData
                    .textTheme
                    .subtitle1
                    .copyWith(
                    color:
                    CustomTheme
                        .of(context)
                        .colors
                        .disabledAreaColor),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: CustomTheme
                      .of(context)
                      .colors
                      .primaryColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: CustomTheme
                          .of(context)
                          .colors
                          .shadowColor16),
                  borderRadius: BorderRadius.circular(5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
