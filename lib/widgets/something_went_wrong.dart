import 'package:flutter/material.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/services/sizeconfig.dart';

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
          Text(
              titleText ??
                  AppTranslations.of(context)
                      .text('generic_something_went_wrong'),
              style: Theme.of(context).textTheme.title),
          SizedBox(
            height: 16.toHeight,
          ),
          Container(
              width: SizeConfig().screenWidth * 0.8,
              child: Text(
                subtitleText ??
                    AppTranslations.of(context)
                        .text('generic_please_check_internet_connection'),
                textAlign: TextAlign.center,
              )),
          SizedBox(
            height: 32.toHeight,
          ),
          FlatButton(
            padding: EdgeInsets.symmetric(
              vertical: 15.toHeight,
              horizontal: 45.toWidth,
            ),
            onPressed: this.onRetry,
            child: Container(
              child: Text(AppTranslations.of(context).text('generic_retry')),
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
