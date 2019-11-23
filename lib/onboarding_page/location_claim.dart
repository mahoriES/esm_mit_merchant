import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/auth.dart';
import 'package:foore/data/bloc/location_claim.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/google_login_not_done_page/google_login_not_done_page.dart';
import 'package:foore/onboarding_page/location_verify.dart';
import 'package:foore/search_gmb/model/google_locations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_translations.dart';

class LocationClaimPage extends StatefulWidget {
  static const routeName = '/location-claim';
  LocationClaimPage({Key key}) : super(key: key);

  @override
  _LocationClaimPageState createState() => _LocationClaimPageState();

  static Route generateRoute(RouteSettings settings,
      {@required HttpService httpService, @required AuthBloc authBloc}) {
    var argumentsForLocationClaim = settings.arguments as Map<String, dynamic>;
    GoogleLocation googleLocation = argumentsForLocationClaim['googleLocation'];
    GmbLocationItem locationItem = argumentsForLocationClaim['locationItem'];
    return MaterialPageRoute(
      builder: (context) => Provider<LocationClaimBloc>(
        builder: (context) => LocationClaimBloc(
          httpService: httpService,
          authBloc: authBloc,
          googleLocation: googleLocation,
          locationItem: locationItem,
        ),
        dispose: (context, value) => value.dispose(),
        child: LocationClaimPage(),
      ),
    );
  }
}

class _LocationClaimPageState extends State<LocationClaimPage>
    with AfterLayoutMixin<LocationClaimPage> {
  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<LocationClaimState> _subscription;

  @override
  void afterFirstLayout(BuildContext context) {
    final LocationClaimBloc locationClaimBloc =
        Provider.of<LocationClaimBloc>(context);
    _subscription = locationClaimBloc.onboardingStateObservable
        .listen(_onLocationClaimChange);
    locationClaimBloc.getData();
  }

  _onLocationClaimChange(LocationClaimState state) {
    if (state.isShowVerificationPending) {
      Navigator.pushNamed(context, LocationVerifyPage.routeName,
          arguments: state.locationItem);
    } else if (state.isShowNotLoggedInWithGoogle) {
      Navigator.pushReplacementNamed(context, GoogleLoginNotDonePage.routeName);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LocationClaimBloc locationClaimBloc =
        Provider.of<LocationClaimBloc>(context);

    onClaim() {
      locationClaimBloc.manageLocation(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context).text("location_claim_page_title")),
      ),
      body: SafeArea(
        child: StreamBuilder<LocationClaimState>(
            stream: locationClaimBloc.onboardingStateObservable,
            builder: (context, snapshot) {
              Widget child = Container();
              if (snapshot.hasData) {
                if (snapshot.data.isLoading) {
                  child = Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.data.isLoadingFailed) {
                  child = Container(
                    child: Text('Loading Failed...'),
                  );
                } else if (snapshot.data.isShowClaimed) {
                  child = claimedBusiness(snapshot.data);
                } else if (snapshot.data.isShowLocation) {
                  child = claimBusiness(snapshot.data, onClaim);
                }
              }
              return child;
            }),
      ),
    );
  }

  Widget claimedBusiness(LocationClaimState state) {
    _launchAdminRightsURL() async {
      final url = state.googleLocation?.requestAdminRightsUrl;
      if (await canLaunch(url)) {
        await launch(url);
      }
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: 32.0,
        ),
        locationDetail(state),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).errorColor.withOpacity(0.2),
          ),
          child: Text(
            AppTranslations.of(context).text("location_claim_page_err_taken"),
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: Theme.of(context).errorColor),
          ),
        ),
        FlatButton(
          child: Text(
            AppTranslations.of(context).text("location_claim_page_button_request_access"),
            style: Theme.of(context).textTheme.button.copyWith(
                  decoration: TextDecoration.underline,
                ),
          ),
          onPressed: _launchAdminRightsURL,
        ),
      ],
    );
  }

  Widget claimBusiness(LocationClaimState state, Function onClaim) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 32.0,
        ),
        locationDetail(state),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          width: double.infinity,
          child: RaisedButton(
            onPressed: onClaim,
            child: state.isSubmitting
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ))
                : Text(
                    AppTranslations.of(context).text("location_claim_page_button_manage"),
                    style: Theme.of(context).textTheme.button.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
          ),
        )
      ],
    );
  }

  Container locationDetail(LocationClaimState state) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: ListTile(
              title: Text(state.locationName ?? ''),
              subtitle: Text(state.locationAddress ?? ''),
            ),
          ),
          Container(
            height: 200.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            child: state.locationLatLang != null
                ? GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        state.locationLatLang.latitude,
                        state.locationLatLang.longitude,
                      ),
                      zoom: 14.4746,
                    ),
                    markers: Set.from([
                      Marker(
                        position: LatLng(
                          state.locationLatLang.latitude,
                          state.locationLatLang.longitude,
                        ),
                        markerId: MarkerId('fooreMarker'),
                      )
                    ]),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
