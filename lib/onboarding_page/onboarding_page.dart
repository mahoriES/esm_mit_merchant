import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        textTheme: Typography.blackMountainView,
        iconTheme: IconThemeData.fallback(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black87,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Locations",
          style: Theme.of(context).textTheme.title,
        ),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Select your Google Business Locations.,',
                  style: Theme.of(context).textTheme.subtitle.apply(
                        color: Theme.of(context).primaryColorDark,
                      ),
                ),
              ),
              CheckboxListTile(
                title: Text(
                  'Foore Data Labs',
                ),
                value: true,
                onChanged: (bool value) {},
              ),
              CheckboxListTile(
                title: Text(
                  'Foore Data Labs',
                ),
                value: true,
                onChanged: (bool value) {},
              ),
              CheckboxListTile(
                title: Text(
                  'Foore Data Labs',
                ),
                value: true,
                onChanged: (bool value) {},
              ),
              Expanded(
                child: Container(),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                width: double.infinity,
                child: RaisedButton(
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
