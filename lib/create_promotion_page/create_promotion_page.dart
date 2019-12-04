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
    return Stack(
      children: <Widget>[
        GoogleMap(
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
        ),
        Scaffold(
          appBar: AppBar(
            title: Text('Create Promotion'),
            automaticallyImplyLeading: true,
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.white,
          body: Column(
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
                      return DropdownButton<FoLocations>(
                        value: snapshot.data.locations[0],
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
                height: 32.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  'You can reach upto 4985 people near your store.',
                  style: Theme.of(context).textTheme.title.copyWith(),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                color: Color.fromRGBO(4, 196, 204, 1),
                padding: EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 30,
                ),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      'Rs. 100-1012 People',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
                    )),
                onPressed: () {},
              ),
              SizedBox(
                height: 12,
              ),
              RaisedButton(
                color: Color.fromRGBO(4, 150, 204, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 30,
                ),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      'Rs. 100-1012 People',
                      textAlign: TextAlign.center,
                    )),
                onPressed: () {},
              ),
              SizedBox(
                height: 12,
              ),
              RaisedButton(
                color: Color.fromRGBO(4, 86, 91, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 30,
                ),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      'Rs. 100-1012 People',
                      textAlign: TextAlign.center,
                    )),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
