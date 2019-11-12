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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Locations",
        ),
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
                  style: Theme.of(context).textTheme.subtitle,
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
