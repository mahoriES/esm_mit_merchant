import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/create_promotion.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class CreatePromotionPage extends StatefulWidget {
  CreatePromotionPage({Key key}) : super(key: key);

  static const routeName = '/create-promotion';

  static Route generateRoute(RouteSettings settings, HttpService httpService) {
    return MaterialPageRoute(
        builder: (context) => Provider(
              builder: (context) =>
                  CreatePromotionBloc(httpService: httpService),
              dispose: (context, value) => value.dispose(),
              child: CreatePromotionPage(),
            ));
  }

  @override
  _CreatePromotionPageState createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends State<CreatePromotionPage>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<CreatePromotionPage> {
  AnimationController _animationController;
  Animation _circleRadius;
  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<CreatePromotionState> _subscription;
  StreamSubscription<OnboardingGuardState> _subscription2;
  final _formKey = GlobalKey<FormState>();

  @override
  void afterFirstLayout(BuildContext context) {
    final createPromotionBloc = Provider.of<CreatePromotionBloc>(context);
    _subscription = createPromotionBloc.CreatePromotionStateObservable.take(1)
        .listen(_onCreatePromotionStateChange);
    createPromotionBloc.getNearbyPromotions();
    final onboardingGuardBloc = Provider.of<OnboardingGuardBloc>(context);
    _subscription2 = onboardingGuardBloc.onboardingStateObservable
        .listen((OnboardingGuardState state) {
      if (state.locations.length > 0) {
        createPromotionBloc.setSelectedLocation(state.locations[0]);
      }
    });
  }

  _onCreatePromotionStateChange(CreatePromotionState state) {
    if (state.screenType == CreatePromotionScreens.sendPromotions) {
      _showIntroAlertDialog();
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _circleRadius = Tween<double>(begin: 40, end: 60).animate(
      CurvedAnimation(
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
        parent: _animationController,
      ),
    );
    playAnimation();
    super.initState();
  }

  _showIntroAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 20.0),
                child: Image(
                  image: AssetImage('assets/promotion-banner.png'),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'Foore lets you send promotions 💌 to new potential customers, near your local business. 🎉🎉🎉'),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  _showConfirmAlertDialog(CreatePromotionBloc promotionBloc) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: StreamBuilder<CreatePromotionState>(
              stream: promotionBloc.CreatePromotionStateObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                if (snapshot.data.isSubmitting) {
                  return Container(
                      width: 50,
                      height: 50,
                      child: Center(child: CircularProgressIndicator()));
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                          'Send this promotional message to ${snapshot.data.numberOfCustomers} people near you.'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Text(
                        '*You will need to pay Rs. ${snapshot.data.price} after approval.',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                );
              }),
          actions: <Widget>[
            FlatButton(
              child: const Text('Confirm'),
              onPressed: () {
                promotionBloc.createPromotion(() {
                  Navigator.of(context).pop();
                });
              },
            )
          ],
        );
      },
    );
  }

  Future<Null> playAnimation() async {
    try {
      await _animationController.repeat(reverse: true).orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subscription.cancel();
    _subscription2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createPromotionBloc = Provider.of<CreatePromotionBloc>(context);
    return Scaffold(
      body: StreamBuilder<CreatePromotionState>(
          stream: createPromotionBloc.CreatePromotionStateObservable,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else if (snapshot.data.screenType ==
                CreatePromotionScreens.loading) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.data.screenType ==
                CreatePromotionScreens.loadingFailed) {
              return SomethingWentWrong(
                onRetry: () {
                  createPromotionBloc.getNearbyPromotions();
                },
              );
            } else if (snapshot.data.screenType ==
                CreatePromotionScreens.sendPromotions) {
              return createPromotion(context);
            } else if (snapshot.data.screenType ==
                CreatePromotionScreens.promotionSent) {
                  // return createPromotion(context);
              return listPromotion(context);
            }
            return Container();
          }),
    );
  }

  Widget listPromotion(BuildContext context) {
    final createPromotionBloc = Provider.of<CreatePromotionBloc>(context);
    final onboardingGuardBloc = Provider.of<OnboardingGuardBloc>(context);
    return SafeArea(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text(
              'My promotions',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'This feature is currently limited to selected customers. Your promotions will be sent after approval from Foore tem. Contact us for more information.',
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          Expanded(
            child: StreamBuilder<CreatePromotionState>(
                stream: createPromotionBloc.CreatePromotionStateObservable,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  final CreatePromotionState promotionData = snapshot.data;
                  return ListView.builder(
                    itemCount: promotionData.promotionList.length,
                    itemBuilder: (context, index) {
                      final promotion = promotionData.promotionList[index];
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  onboardingGuardBloc.getLocationNameById(
                                      promotion.locationId),
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  promotion.getCreatedTimeText(),
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              promotion.promoMessage,
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              promotion.promoReach,
                              style:
                                  Theme.of(context).textTheme.caption.copyWith(
                                        color: Colors.grey[900],
                                      ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Approval pending',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(
                                      color: Colors.yellow[800],
                                      fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: FoSubmitButton(
              text: 'Contact us',
              onPressed: () async {
                await Share.whatsAppTo('+917829862689');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget createPromotion(BuildContext context) {
    final onboardingGuardBloc = Provider.of<OnboardingGuardBloc>(context);
    final promotionBloc = Provider.of<CreatePromotionBloc>(context);
    return Form(
      key: this._formKey,
      child: ListView(
        children: <Widget>[
          Container(
            height: 400.0,
            child: Stack(
              children: <Widget>[
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, _) {
                    return GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          12.9829735,
                          77.687969,
                        ),
                        zoom: 14.4746,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      circles: Set.from([
                        Circle(
                          circleId: CircleId('foCircle'),
                          center: LatLng(
                            12.9829735,
                            77.687969,
                          ),
                          radius: _circleRadius.value,
                          fillColor: Colors.blue,
                          strokeWidth: 0,
                        ),
                        Circle(
                          circleId: CircleId('foCircle2'),
                          center: LatLng(
                            12.9829735,
                            77.687969,
                          ),
                          radius: 200,
                          fillColor: Colors.blue[400].withOpacity(0.12),
                          strokeWidth: 1,
                          strokeColor: Colors.blue[100],
                        ),
                        Circle(
                          circleId: CircleId('foCircle3'),
                          center: LatLng(
                            12.9829735,
                            77.687969,
                          ),
                          radius: 500,
                          fillColor: Colors.blue[200].withOpacity(0.12),
                          strokeWidth: 1,
                          strokeColor: Colors.blue[100],
                        ),
                        Circle(
                          circleId: CircleId('foCircle4'),
                          center: LatLng(
                            12.9829735,
                            77.687969,
                          ),
                          radius: 1000,
                          fillColor: Colors.blue[200].withOpacity(0.12),
                          strokeWidth: 1,
                          strokeColor: Colors.blue[100],
                        ),
                      ]),
                    );
                  },
                ),
                Positioned(
                  child: StreamBuilder<OnboardingGuardState>(
                    stream: onboardingGuardBloc.onboardingStateObservable,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.locations.length < 2) {
                          return SafeArea(
                            child: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        } else
                          return Container();
                      } else
                        return Container();
                    },
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 16,
                  right: 16,
                  child: StreamBuilder<OnboardingGuardState>(
                      stream: onboardingGuardBloc.onboardingStateObservable,
                      builder: (context, onboardingSnapshot) {
                        if (!onboardingSnapshot.hasData) {
                          return Container();
                        }

                        if (onboardingSnapshot.data.locations.length > 1) {
                          return StreamBuilder<CreatePromotionState>(
                              stream:
                                  promotionBloc.CreatePromotionStateObservable,
                              builder: (context, promotionSnapshot) {
                                if (!promotionSnapshot.hasData) {
                                  return Container();
                                }
                                return SafeArea(
                                  child: Material(
                                    borderRadius: BorderRadius.circular(4),
                                    elevation: 12,
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.arrow_back),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: DropdownButton<FoLocations>(
                                              value: promotionSnapshot
                                                  .data.selectedLocation,
                                              underline: Container(),
                                              icon: Transform.rotate(
                                                  angle: math.pi / 2.0,
                                                  child: Icon(
                                                      Icons.chevron_right)),
                                              isExpanded: true,
                                              onChanged: (value) {
                                                promotionBloc
                                                    .setSelectedLocation(value);
                                              },
                                              items: onboardingSnapshot
                                                  .data.locations
                                                  .map<
                                                      DropdownMenuItem<
                                                          FoLocations>>(
                                                      (FoLocations
                                                          locationItem) {
                                                return DropdownMenuItem<
                                                    FoLocations>(
                                                  value: locationItem,
                                                  child:
                                                      Text(locationItem.name),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                        return Container();
                      }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: promotionBloc.messageEditController,
              minLines: 3,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Type your promotional message',
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                return value.length < 1 ? 'Required' : null;
              },
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            margin: EdgeInsets.symmetric(horizontal: 16),
            // color: Colors.green[100],
            child: Text(
              'You can reach up to 4985 people near your store.',
              style: Theme.of(context).textTheme.body1.copyWith(
                    color: Colors.green[700],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              color: Color.fromRGBO(4, 196, 204, 1),
              padding: EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 30,
              ),
              child: Text(
                'Rs. 100-1012 People',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.white),
              ),
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  promotionBloc.setPromoReach('Rs. 100-1012 People', 100, 33);
                  this._showConfirmAlertDialog(promotionBloc);
                }
              },
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: RaisedButton(
              color: Color.fromRGBO(4, 150, 204, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 30,
              ),
              child: Text(
                'Rs. 100-1012 People',
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  promotionBloc.setPromoReach('Rs. 200-1012 People', 100, 35);
                  this._showConfirmAlertDialog(promotionBloc);
                }
              },
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: RaisedButton(
              color: Color.fromRGBO(4, 86, 91, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              padding: EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 30,
              ),
              child: Text(
                'Rs. 100-1012 People',
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  promotionBloc.setPromoReach('Rs. 300-1012 People', 100, 53);
                  this._showConfirmAlertDialog(promotionBloc);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
