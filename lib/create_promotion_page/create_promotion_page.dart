import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/onboarding_guard.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

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

class _CreatePromotionPageState extends State<CreatePromotionPage> {
  Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    final onboardingGuardBloc = Provider.of<OnboardingGuardBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Promotion'),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 12,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            child: StreamBuilder<OnboardingGuardState>(
                stream: onboardingGuardBloc.onboardingStateObservable,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  var value = null;
                  if (snapshot.data.locations.length > 0) {
                    value = snapshot.data.locations[0];
                  }
                  return DropdownButton<FoLocations>(
                    value: value,
                    elevation: 4,
                    onChanged: (value) {},
                    items: snapshot.data.locations
                        .map<DropdownMenuItem<FoLocations>>(
                            (FoLocations locationItem) {
                      return DropdownMenuItem<FoLocations>(
                        value: locationItem,
                        child: Text(locationItem.name),
                      );
                    }).toList(),
                  );
                }),
          ),
          SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            child: Text(
              'Send messages to nearby customers',
              style: Theme.of(context).textTheme.subtitle,
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
            height: 16.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Material(
              elevation: 2,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 200,
                    child: GoogleMap(
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
                          radius: 50,
                          fillColor: Colors.blue,
                          strokeWidth: 0,
                        ),
                        Circle(
                          circleId: CircleId('foCircle2'),
                          center: LatLng(
                            12.9829735,
                            77.687969,
                          ),
                          radius: 240,
                          fillColor: Colors.blue[100].withOpacity(0.12),
                          strokeWidth: 6,
                          strokeColor: Colors.blue[100],
                        ),
                      ]),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    color: Colors.green[100],
                    child: Text(
                      'You can reach upto 4985 people near your store.',
                      style: Theme.of(context).textTheme.body1.copyWith(
                            color: Colors.green[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
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
