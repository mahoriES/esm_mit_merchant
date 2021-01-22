import 'package:circles/secret_circle_sheet_widget.dart';
import 'package:flutter/material.dart';
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

  Function onAddCallback;

  @override
  void initState() {
    _esSelectCircleBloc =
        Provider.of<EsSelectCircleBloc>(context, listen: false);
    _esSelectCircleBloc.getTrendingCircles();
    _esSelectCircleBloc.getNearbyCircles();
    onAddCallback = (circleCode) {
      Navigator.pop(context, EsCluster(clusterCode: circleCode,
          clusterId: '',
          clusterName: circleCode,
          description: 'Circle added via Code'));
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const locationPointerImage = "assets/location-pointer.png";
    return Theme(
      data: CustomTheme
          .of(context)
          .themeData,
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
                      trendingCirclesLabelLocalisedString: "Trending Circles",
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
                      "Suggested Circles",
                      turnOnLocationLocalisedString: "Turn Location On",
                      circleLocationLocalisedString:
                      "Turn on your device's location to get suggestions for Circles near you",
                      locationPointerImagePath: locationPointerImage,
                      nearbyCircleLabelLocalisedString:
                      "Based on your current location",
                    ),
                    CircleInfoFooter(
                        onTapCallBack: () =>
                            showSecretCircleAdderDialog(context, onAddCallback),
                        isAdvancedUser: () =>
                            _esSelectCircleBloc.isAdvancedUser(),
                        circleBrandingLocalisedText: "eSamudaay Circles",
                        circleInfo1LocalisedText:
                        "A 'Circle' is a community of shop owners, restaurants and merchants that serve in a locality",
                        circleInfo2LocalisedText:
                        "You can add a circle by turning on your location or searching for a specific circle",
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
            child: SecretCircleBottomSheet(
              onAddCircle: onAddCallback,
              circleEnterCodeLocalisedString: "Enter Circle Code",
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
                hintText: "Search for a Circle",
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
