import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';

class EmptyList extends StatelessWidget {
  final String titleText;
  final String subtitleText;
  const EmptyList({this.titleText, this.subtitleText});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Image(
              image: AssetImage('assets/empty-state.png'),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Text(
              titleText ??
                  AppTranslations.of(context).text('generic_no_items_found'),
              style: Theme.of(context).textTheme.title),
          SizedBox(
            height: 16,
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                subtitleText ?? '',
                textAlign: TextAlign.center,
              )),
          Flexible(
            flex: 3,
            child: Container(),
          ),
        ],
      ),
    );
  }
}
