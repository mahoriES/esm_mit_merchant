import 'package:flutter/material.dart';

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
}

Widget get placeHolderImage {
  return Image.asset(
    'assets/category_placeholder.png',
    fit: BoxFit.cover,
  );
}
