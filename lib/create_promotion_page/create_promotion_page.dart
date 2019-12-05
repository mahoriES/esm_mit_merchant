import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class CreatePromotionPage extends StatefulWidget {
  CreatePromotionPage({Key key}) : super(key: key);

  static const routeName = '/create-promotion';

  static Route generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => CreatePromotionPage(),
    );
  }

  @override
  _CreatePromotionPageState createState() => _CreatePromotionPageState();
}

class _CreatePromotionPageState extends State<CreatePromotionPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _circleRadius;
  Completer<GoogleMapController> _controller = Completer();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingGuardBloc = Provider.of<OnboardingGuardBloc>(context);
    return Scaffold(
      body: ListView(
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
                          circleId: CircleId('foCircl3'),
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
                      }
                    },
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 16,
                  right: 16,
                  child: StreamBuilder<OnboardingGuardState>(
                      stream: onboardingGuardBloc.onboardingStateObservable,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        var value = null;
                        if (snapshot.data.locations.length > 1) {
                          value = snapshot.data.locations[0];
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
                                    // Navigator.of(context).pop();
                                    playAnimation();
                                  },
                                ),
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: DropdownButton<FoLocations>(
                                      value: value,
                                      underline: Container(),
                                      icon: Transform.rotate(
                                          angle: math.pi / 2.0,
                                          child: Icon(Icons.chevron_right)),
                                      isExpanded: true,
                                      onChanged: (value) {},
                                      items: snapshot.data.locations
                                          .map<DropdownMenuItem<FoLocations>>(
                                              (FoLocations locationItem) {
                                        return DropdownMenuItem<FoLocations>(
                                          value: locationItem,
                                          child: Text(locationItem.name),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              minLines: 3,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Type your promotional message',
                border: OutlineInputBorder(),
              ),
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
              onPressed: () {},
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
              onPressed: () {},
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
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
