import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static String getTimeDiffrence(String timeString) {
    DateTime createdAt = DateTime.parse(timeString).toLocal();
    DateTime currentTime = DateTime.now();
    Duration diffrence = currentTime.difference(createdAt);

    String displayText;

    if (diffrence.inSeconds < 60)
      displayText =
          '${diffrence.inSeconds} second${diffrence.inSeconds > 1 ? 's' : ''} ago';
    else if (diffrence.inMinutes < 60)
      displayText =
          '${diffrence.inMinutes} minute${diffrence.inMinutes > 1 ? 's' : ''} ago';
    else if (diffrence.inHours < 24)
      displayText =
          '${diffrence.inHours} hour${diffrence.inHours > 1 ? 's' : ''} ago';
    else if (diffrence.inDays < 7)
      displayText =
          '${diffrence.inDays} day${diffrence.inDays > 1 ? 's' : ''} ago';
    else if (diffrence.inDays < 31)
      displayText =
          '${diffrence.inDays ~/ 7} week${diffrence.inDays ~/ 7 > 1 ? 's' : ''} ago';
    else
      displayText =
          '${diffrence.inDays ~/ 31} month${diffrence.inDays ~/ 31 > 1 ? 's' : ''} ago';

    return displayText;
  }

  /// makeQuery takes queryParameters as a collection of key/value pairs and converts
  /// into a query string.
  static String makeQuery(Map<String, String> queryParameters) {
    final result = StringBuffer();
    var separator = "?";

    /// writeParameter takes key and value of a query parameter and converts
    /// into a query string.
    void writeParameter(String key, String value) {
      result.write(separator);
      separator = "&";
      result.write(Uri.encodeQueryComponent(key));
      if (value != null && value.isNotEmpty) {
        result.write("=");
        result.write(Uri.encodeQueryComponent(value));
      }
    }

    queryParameters.forEach((key, value) {
      if (value == null || value is String) {
        writeParameter(key, value);
      }
    });

    return result.toString();
  }

  static int getPriceInPaisa(input) {
    double priceInRupees = double.tryParse(input) ?? 0;
    int priceInPaisa = (priceInRupees * 100).round();
    return priceInPaisa;
  }

  static int getPriceInPercent(input) {
    double price = double.tryParse(input) ?? 0;
    return price.round();
  }
}

Widget get placeHolderImage {
  return Image.asset(
    'assets/category_placeholder.png',
    fit: BoxFit.cover,
  );
}

Future<void> showFailedAlertDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Submit failed'),
        content: const Text('Please try again.'),
        actions: <Widget>[
          FlatButton(
            child: const Text('Dismiss'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

String getPriceStringWithoutRupeeSymbol(int price) {
  if (price != null) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '')
        .format(price / 100);
  }
  return '0.00';
}
