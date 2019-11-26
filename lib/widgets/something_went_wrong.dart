import 'package:flutter/material.dart';

class SomethingWentWrong extends StatelessWidget {
  final String titleText;
  final Function onRetry;
  final String subtitleText;
  const SomethingWentWrong({this.titleText, this.subtitleText, this.onRetry});

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
          Text(titleText ?? 'Something went wrong',
              style: Theme.of(context).textTheme.title),
          SizedBox(
            height: 16,
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                subtitleText ??
                    'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
              )),
          SizedBox(
            height: 32,
          ),
          FlatButton(
            padding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 45,
            ),
            onPressed: this.onRetry,
            child: Container(
              child: Text('Retry'),
            ),
          ),
          Flexible(
            flex: 3,
            child: Container(),
          ),
        ],
      ),
    );
  }
}
