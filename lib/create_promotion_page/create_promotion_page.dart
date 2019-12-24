import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/create_promotion.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:sprintf/sprintf.dart';

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
  Completer<GoogleMapController> _isReady = Completer();
  StreamSubscription<CreatePromotionState> _subscription;
  StreamSubscription<OnboardingGuardState> _subscription2;
  final _formKey = GlobalKey<FormState>();
  bool isIntroDialogShown = false;

  Set<Marker> markers = Set.from([]);

  @override
  void afterFirstLayout(BuildContext context) {
    final createPromotionBloc = Provider.of<CreatePromotionBloc>(context);
    _subscription = createPromotionBloc.CreatePromotionStateObservable.listen(
        _onCreatePromotionStateChange);
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
    if (state.screenType == CreatePromotionScreens.sendPromotions &&
        !isIntroDialogShown) {
      _showIntroAlertDialog();
      isIntroDialogShown = true;
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
                child: Text(AppTranslations.of(context)
                    .text('create_promotion_page_help_description')),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppTranslations.of(context)
                  .text('create_promotion_page_help_button_continue')),
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
          title: StreamBuilder<CreatePromotionState>(
              stream: promotionBloc.CreatePromotionStateObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                if (snapshot.data.isSubmitting) {
                  return Container();
                }
                return Text(AppTranslations.of(context)
                    .text('create_promotion_page_confirm_title'));
              }),
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
                      child: Text(sprintf(
                          AppTranslations.of(context)
                              .text('create_promotion_page_confirm_subtitle'),
                          [snapshot.data.numberOfCustomers])),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8.0),
                      child: Text(
                        sprintf(
                            AppTranslations.of(context)
                                .text('create_promotion_page_confirm_tip'),
                            [snapshot.data.price]),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                );
              }),
          actions: <Widget>[
            StreamBuilder<CreatePromotionState>(
                stream: promotionBloc.CreatePromotionStateObservable,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  if (snapshot.data.isSubmitting) {
                    return Container();
                  }

                  return FlatButton(
                    child: Text(AppTranslations.of(context)
                        .text('create_promotion_page_button_confirm')),
                    onPressed: () {
                      promotionBloc.createPromotion(() {
                        Navigator.of(context).pop();
                      });
                    },
                  );
                })
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
              AppTranslations.of(context).text('promotion_list_page_title'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppTranslations.of(context).text('promotion_list_page_sub-title'),
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
                          vertical: 8.0,
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
                            Container(
                                child: promotionState(promotion, snapshot.data,
                                    createPromotionBloc)),
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
              text: AppTranslations.of(context)
                  .text('promotion_list_page_contact-us'),
              onPressed: () async {
                await Share.whatsAppTo('+917829862689');
              },
            ),
          ),
        ],
      ),
    );
  }

  promotionState(PromotionItem promotion, CreatePromotionState state,
      CreatePromotionBloc createPromotionBloc) {
    if (promotion.paymentState == PaymentState.pending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppTranslations.of(context)
                .text('promotion_list_page_payment_pending'),
            style: Theme.of(context).textTheme.caption.copyWith(
                  color: Colors.yellow[800],
                ),
          ),
          SizedBox(
            height: 8.0,
          ),
          FoSubmitButton(
              text: AppTranslations.of(context)
                  .text('promotion_list_page_button_pay'),
              onPressed: () {
                createPromotionBloc.createPayment(promotion);
              },
              isLoading: state.isPaymentSubmitting &&
                  state.promotionBeingPaid == promotion.promoId,
              isSuccess: state.isPaymentSubmitSuccess &&
                  state.promotionBeingPaid == promotion.promoId)
        ],
      );
    } else if (promotion.paymentState == PaymentState.refunded) {
      return Text(
        AppTranslations.of(context).text('promotion_list_page_refunded'),
        style: Theme.of(context)
            .textTheme
            .caption
            .copyWith(color: Colors.yellow[800], fontWeight: FontWeight.w600),
      );
    } else if (promotion.paymentState == PaymentState.done) {
      if (promotion.promoState == PromoState.pending) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppTranslations.of(context)
                  .text('promotion_list_page_payment_done'),
              style: Theme.of(context).textTheme.caption.copyWith(
                    color: Colors.black54,
                  ),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              AppTranslations.of(context)
                  .text('promotion_list_page_approval_pending'),
              style: Theme.of(context).textTheme.caption.copyWith(
                  color: Colors.yellow[800], fontWeight: FontWeight.w600),
            )
          ],
        );
      } else if (promotion.promoState == PromoState.rejected) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppTranslations.of(context)
                  .text('promotion_list_page_payment_done'),
              style: Theme.of(context).textTheme.caption.copyWith(
                    color: Colors.black54,
                  ),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              AppTranslations.of(context)
                  .text('promotion_list_page_approval_rejected'),
              style: Theme.of(context).textTheme.caption.copyWith(
                  color: Colors.red[800], fontWeight: FontWeight.w600),
            )
          ],
        );
      } else if (promotion.promoState == PromoState.approved) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppTranslations.of(context)
                  .text('promotion_list_page_payment_done'),
              style: Theme.of(context).textTheme.caption.copyWith(
                    color: Colors.black54,
                  ),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              AppTranslations.of(context)
                  .text('promotion_list_page_approval_done'),
              style: Theme.of(context).textTheme.caption.copyWith(
                  color: Colors.green[800], fontWeight: FontWeight.w600),
            )
          ],
        );
      }
    }
  }

  Future<Uint8List> getBytesFromCanvas(
      int width, int height, String storeName) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.white60;
    final Radius radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: storeName.length > 25 ? storeName.substring(0, 24) : storeName,
      style: TextStyle(fontSize: 25.0, color: Colors.black),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  setMarkers(String storeName, LatLng latLang) async {
    final Uint8List markerIcon = await getBytesFromCanvas(300, 50, storeName);
    final Marker marker = Marker(
        markerId: MarkerId('foMarker'),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: latLang);
    setState(() {
      this.markers = Set.from([marker]);
    });
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
                StreamBuilder<CreatePromotionState>(
                    stream: promotionBloc.CreatePromotionStateObservable,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      var latLang = LatLng(
                        0,
                        0,
                      );
                      if (snapshot.data.selectedLocation != null) {
                        if (snapshot.data.selectedLocation.metaData != null) {
                          latLang = LatLng(
                            snapshot.data.selectedLocation.metaData.latitude ??
                                0,
                            snapshot.data.selectedLocation.metaData.longitude ??
                                0,
                          );
                          this.setMarkers(
                              snapshot.data.selectedLocation.name ?? '',
                              latLang);
                          _isReady.future.then((controller) {
                            controller.moveCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                              target: latLang,
                              zoom: 14.4746,
                            )));
                          });
                        }
                      }
                      return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, _) {
                            return GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: latLang,
                                zoom: 14.4746,
                              ),
                              onMapCreated: (GoogleMapController controller) {
                                _isReady.complete(controller);
                              },
                              markers: this.markers,
                              circles: Set.from([
                                Circle(
                                  circleId: CircleId('foCircle'),
                                  center: latLang,
                                  radius: _circleRadius.value,
                                  fillColor: Colors.blue,
                                  strokeWidth: 0,
                                ),
                                Circle(
                                  circleId: CircleId('foCircle2'),
                                  center: latLang,
                                  radius: 200,
                                  fillColor: Colors.blue[400].withOpacity(0.12),
                                  strokeWidth: 1,
                                  strokeColor: Colors.blue[100],
                                ),
                                Circle(
                                  circleId: CircleId('foCircle3'),
                                  center: latLang,
                                  radius: 500,
                                  fillColor: Colors.blue[200].withOpacity(0.12),
                                  strokeWidth: 1,
                                  strokeColor: Colors.blue[100],
                                ),
                                Circle(
                                  circleId: CircleId('foCircle4'),
                                  center: latLang,
                                  radius: 1000,
                                  fillColor: Colors.blue[200].withOpacity(0.12),
                                  strokeWidth: 1,
                                  strokeColor: Colors.blue[100],
                                ),
                              ]),
                            );
                          });
                    }),
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
                labelText: AppTranslations.of(context)
                    .text('create_promotion_page_message_input_label'),
                border: OutlineInputBorder(),
              ),
              validator: (String value) {
                return value.length < 1 ? 'Required' : null;
              },
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            margin: EdgeInsets.symmetric(horizontal: 16),
            // color: Colors.green[100],
            child: Text(
              sprintf(
                  AppTranslations.of(context)
                      .text('create_promotion_page_people_reach_message'),
                  [promotionBloc.buttonOneCal.toString()]),
              style: Theme.of(context).textTheme.subhead.copyWith(
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
                sprintf(
                    AppTranslations.of(context)
                        .text('create_promotion_page_submit'),
                    ['100', promotionBloc.buttonThreeCal.toString()]),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.white),
              ),
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  promotionBloc.setPromoReach(
                      'Rs. 100-${promotionBloc.buttonThreeCal.toString()} People',
                      promotionBloc.buttonThreeCal,
                      100);
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
                sprintf(
                    AppTranslations.of(context)
                        .text('create_promotion_page_submit'),
                    ['300', promotionBloc.buttonTwoCal.toString()]),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  promotionBloc.setPromoReach(
                      'Rs. 300-${promotionBloc.buttonTwoCal.toString()} People',
                      promotionBloc.buttonTwoCal,
                      300);
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
                sprintf(
                    AppTranslations.of(context)
                        .text('create_promotion_page_submit'),
                    ['500', promotionBloc.buttonOneCal.toString()]),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                if (this._formKey.currentState.validate()) {
                  promotionBloc.setPromoReach(
                      'Rs. 500-${promotionBloc.buttonOneCal.toString()} People',
                      promotionBloc.buttonOneCal,
                      500);
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
